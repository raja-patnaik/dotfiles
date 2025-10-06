#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
COMPONENTS=()
OS_TYPE=""
IS_WSL=false

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -qi microsoft /proc/version 2>/dev/null; then
            OS_TYPE="wsl"
            IS_WSL=true
        else
            OS_TYPE="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS_TYPE="windows-bash"
    else
        log_error "Unsupported OS: $OSTYPE"
    fi
    log_info "Detected OS: $OS_TYPE"
}

check_dependencies() {
    local deps=("git" "curl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_error "Required dependency '$dep' is not installed"
        fi
    done
}

install_homebrew() {
    if [[ "$OS_TYPE" == "macos" ]] || [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
        if ! command -v brew &>/dev/null; then
            log_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH
            if [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.profile"
            fi
        else
            log_info "Homebrew already installed"
        fi
    fi
}

install_stow() {
    if ! command -v stow &>/dev/null; then
        log_info "Installing GNU Stow..."
        if [[ "$OS_TYPE" == "macos" ]]; then
            brew install stow
        elif [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
            if command -v apt-get &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y stow
            elif command -v yum &>/dev/null; then
                sudo yum install -y stow
            elif command -v brew &>/dev/null; then
                brew install stow
            else
                log_error "Cannot install stow: no supported package manager found"
            fi
        fi
    else
        log_info "GNU Stow already installed"
    fi
}

backup_existing_configs() {
    log_info "Backing up existing configurations to $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"

    # List of config files/dirs to backup
    local configs=(
        ".zshrc" ".zshenv" ".bashrc" ".bash_profile"
        ".gitconfig" ".tmux.conf" ".wezterm.lua"
        ".config/nvim" ".config/starship.toml"
        ".config/lazygit" ".config/atuin"
    )

    for config in "${configs[@]}"; do
        if [[ -e "$HOME/$config" ]]; then
            local backup_path="$BACKUP_DIR/$config"
            mkdir -p "$(dirname "$backup_path")"
            cp -r "$HOME/$config" "$backup_path" 2>/dev/null || true
            log_info "Backed up $config"
        fi
    done
}

install_packages() {
    log_info "Installing packages..."

    case "$OS_TYPE" in
        macos)
            if [[ -f "$DOTFILES_DIR/packages/brew.txt" ]]; then
                log_info "Installing macOS packages..."
                brew bundle --file="$DOTFILES_DIR/packages/Brewfile"
            fi
            ;;
        linux|wsl)
            if command -v apt-get &>/dev/null && [[ -f "$DOTFILES_DIR/packages/apt.txt" ]]; then
                log_info "Installing apt packages..."
                cat "$DOTFILES_DIR/packages/apt.txt" | grep -v '^\s*#' | grep -v '^\s*$' | xargs sudo apt-get install -y
            fi
            if command -v brew &>/dev/null && [[ -f "$DOTFILES_DIR/packages/brew-linux.txt" ]]; then
                log_info "Installing Homebrew packages..."
                cat "$DOTFILES_DIR/packages/brew-linux.txt" | grep -v '^\s*#' | grep -v '^\s*$' | xargs brew install
            fi
            ;;
    esac

    # Install Rust and cargo tools
    if ! command -v cargo &>/dev/null; then
        log_info "Installing Rust via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        log_info "Updating Rust to latest stable..."
        rustup update stable
    fi

    # Install cargo tools
    local cargo_tools=("zoxide" "eza" "bat" "ripgrep" "fd-find" "sd" "git-delta" "atuin")
    for tool in "${cargo_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            log_info "Installing $tool..."
            cargo install "$tool"
        fi
    done

    # Install tree-sitter CLI via npm if not available
    if ! command -v tree-sitter &>/dev/null; then
        if command -v npm &>/dev/null; then
            log_info "Installing tree-sitter CLI via npm..."
            npm install -g tree-sitter-cli
        else
            log_warning "npm not found, skipping tree-sitter CLI installation"
        fi
    fi
}

stow_configs() {
    log_info "Stowing configurations..."
    cd "$DOTFILES_DIR"

    # Stow each component
    local components=(
        "common/git"
        "shell/zsh"
        "shell/bash"
        "shell/starship"
        "terminal/wezterm"
        "editor/nvim"
        "tools/tmux"
        "tools/bat"
        "tools/eza"
        "tools/fzf"
        "tools/lazygit"
        "tools/atuin"
        "tools/direnv"
    )

    for component in "${components[@]}"; do
        if [[ -d "$component" ]]; then
            log_info "Stowing $component..."
            stow -v -t "$HOME" -d "$(dirname "$component")" "$(basename "$component")"
        fi
    done
}

setup_shell() {
    log_info "Setting up shell..."

    # Change default shell to zsh if not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        if command -v zsh &>/dev/null; then
            log_info "Changing default shell to zsh..."
            chsh -s "$(which zsh)"
        fi
    fi

    log_info "Zsh plugins will be auto-installed on first launch via .zshrc"
}

install_mise() {
    if ! command -v mise &>/dev/null; then
        log_info "Installing mise..."
        curl https://mise.run | sh
        eval "$(~/.local/bin/mise activate bash)"
    fi
}

install_nix() {
    if ! command -v nix &>/dev/null; then
        log_info "Installing Nix..."
        log_warning "Nix installation requires sudo and will modify system files"
        read -p "Continue with Nix installation? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [[ "$OS_TYPE" == "macos" ]] || [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
                # Install Nix with flakes enabled
                sh <(curl -L https://nixos.org/nix/install) --daemon --yes

                # Enable flakes and nix-command
                mkdir -p ~/.config/nix
                cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
                log_success "Nix installed! Restart your shell to use it."
            else
                log_warning "Nix installation not supported on this platform"
            fi
        else
            log_info "Skipping Nix installation"
        fi
    else
        log_info "Nix already installed"

        # Ensure flakes are enabled
        if ! grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf 2>/dev/null; then
            log_info "Enabling Nix flakes..."
            mkdir -p ~/.config/nix
            echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        fi
    fi
}

setup_neovim() {
    log_info "Setting up Neovim with LazyVim..."

    # Install Neovim if not present
    if ! command -v nvim &>/dev/null; then
        log_info "Installing Neovim..."
        if [[ "$OS_TYPE" == "macos" ]]; then
            brew install neovim
        else
            # Install from AppImage for latest version
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            sudo mv nvim.appimage /usr/local/bin/nvim
        fi
    fi

    # Install LazyVim
    if [[ ! -d "$HOME/.config/nvim" ]]; then
        log_info "Installing LazyVim..."
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
        rm -rf "$HOME/.config/nvim/.git"
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --only)
            IFS=',' read -ra COMPONENTS <<< "$2"
            shift 2
            ;;
        --help)
            cat << EOF
Usage: $0 [OPTIONS]

Options:
    --dry-run       Preview changes without applying them
    --only <list>   Install only specified components (comma-separated)
    --help          Show this help message

Components:
    packages, stow, shell, neovim, mise, nix, all

Example:
    $0 --only packages,shell
EOF
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            ;;
    esac
done

# Main execution
main() {
    log_info "Starting dotfiles installation..."

    detect_os
    check_dependencies

    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi

    # If no specific components, install all
    if [[ ${#COMPONENTS[@]} -eq 0 ]]; then
        COMPONENTS=("all")
    fi

    # Execute based on components
    if [[ " ${COMPONENTS[@]} " =~ " all " ]]; then
        backup_existing_configs
        install_homebrew
        install_stow
        install_packages
        stow_configs
        setup_shell
        install_mise
        install_nix
        setup_neovim
    else
        for component in "${COMPONENTS[@]}"; do
            case "$component" in
                packages)
                    install_homebrew
                    install_packages
                    ;;
                stow)
                    install_stow
                    stow_configs
                    ;;
                shell)
                    setup_shell
                    ;;
                neovim)
                    setup_neovim
                    ;;
                mise)
                    install_mise
                    ;;
                nix)
                    install_nix
                    ;;
                *)
                    log_warning "Unknown component: $component"
                    ;;
            esac
        done
    fi

    log_success "Dotfiles installation completed!"
    log_info "Please restart your shell or run: source ~/.zshrc"
}

# Run main function
main