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
SKIP_DOCKER=false

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

# Run a command, or just print it in dry-run mode
run_cmd() {
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN] Would run: $*"
  else
    "$@"
  fi
}

cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    log_warning "Installation interrupted (exit code: $exit_code). Some changes may have been partially applied."
    if [[ -d "$BACKUP_DIR" ]]; then
      log_info "Your original configs were backed up to: $BACKUP_DIR"
    fi
  fi
}
trap cleanup EXIT

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

setup_locale() {
  if [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
    # Check if locale is already generated
    if ! locale -a | grep -q "en_US.utf8"; then
      log_info "Generating en_US.UTF-8 locale..."
      run_cmd sudo locale-gen en_US.UTF-8
      run_cmd sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
      log_success "Locale configured"
    else
      log_info "Locale en_US.UTF-8 already configured"
    fi
  fi
}

install_homebrew() {
  if [[ "$OS_TYPE" == "macos" ]] || [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
    if ! command -v brew &>/dev/null; then
      log_info "Installing Homebrew..."
      run_cmd /bin/bash -c "NONINTERACTIVE=1 CI=1 /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""

      # Add Homebrew to PATH
      if [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
        local brew_line=""
        if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
          brew_line='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
        elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
          eval "$($HOME/.linuxbrew/bin/brew shellenv)"
          brew_line='eval "$($HOME/.linuxbrew/bin/brew shellenv)"'
        fi
        if [[ -n "$brew_line" ]] && ! grep -qF "$brew_line" "$HOME/.profile" 2>/dev/null; then
          run_cmd bash -c "echo '$brew_line' >> \"\$HOME/.profile\""
        fi
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
      run_cmd brew install stow
    elif [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
      if command -v apt-get &>/dev/null; then
        run_cmd sudo apt-get update && run_cmd sudo apt-get install -y stow
      elif command -v yum &>/dev/null; then
        run_cmd sudo yum install -y stow
      elif command -v brew &>/dev/null; then
        run_cmd brew install stow
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
  run_cmd mkdir -p "$BACKUP_DIR"

  # List of config files/dirs to backup
  local configs=(
    ".zshrc" ".zshenv" ".bashrc" ".bash_profile"
    ".gitconfig" ".tmux.conf"
    ".config/nvim" ".config/starship.toml"
    ".config/lazygit" ".config/atuin"
  )

  for config in "${configs[@]}"; do
    if [[ -e "$HOME/$config" ]]; then
      local backup_path="$BACKUP_DIR/$config"
      run_cmd mkdir -p "$(dirname "$backup_path")"
      run_cmd cp -r "$HOME/$config" "$backup_path"
      run_cmd rm -rf "$HOME/$config"
      log_info "Backed up $config"
    fi
  done
}

install_packages() {
  log_info "Installing packages..."

  case "$OS_TYPE" in
  macos)
    if [[ -f "$DOTFILES_DIR/packages/Brewfile" ]]; then
      log_info "Installing macOS packages..."
      run_cmd brew bundle --file="$DOTFILES_DIR/packages/Brewfile"
    fi
    ;;
  linux | wsl)
    if command -v apt-get &>/dev/null && [[ -f "$DOTFILES_DIR/packages/apt.txt" ]]; then
      log_info "Installing apt packages..."
      run_cmd sudo apt-get update
      run_cmd bash -c "grep -v '^\s*#' '$DOTFILES_DIR/packages/apt.txt' | grep -v '^\s*$' | xargs -r sudo apt-get install -y"
    fi
    if command -v brew &>/dev/null && [[ -f "$DOTFILES_DIR/packages/brew-linux.txt" ]]; then
      log_info "Installing Homebrew packages..."
      run_cmd bash -c "grep -v '^\s*#' '$DOTFILES_DIR/packages/brew-linux.txt' | grep -v '^\s*$' | xargs -r brew install"
    fi
    ;;
  esac

  # Install Rust and cargo tools
  # Always clean up old apt-based cargo installations first (Linux/WSL only)
  if [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
    log_info "Cleaning up old apt cargo installations..."
    run_cmd sudo apt-get remove -y cargo rustc 2>/dev/null || true
    run_cmd rm -rf ~/.local/share/cargo 2>/dev/null || true
  fi

  # Unset old cargo environment variables and set correct paths
  unset CARGO_HOME RUSTUP_HOME
  export CARGO_HOME="$HOME/.cargo"
  export RUSTUP_HOME="$HOME/.rustup"

  if ! command -v rustup &>/dev/null; then
    log_info "Installing Rust via rustup..."
    run_cmd rm -rf ~/.cargo ~/.rustup 2>/dev/null || true
    run_cmd bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
  else
    log_info "Updating Rust to latest stable..."
    if ! rustup update stable 2>/dev/null; then
      log_warning "Rustup update failed, reinstalling..."
      run_cmd rm -rf ~/.cargo ~/.rustup ~/.local/share/cargo 2>/dev/null || true
      run_cmd bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    fi
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
  fi

  # Install cargo tools (map cargo crate names to executable names)
  local cargo_tools=(
    "zoxide:zoxide"
    "eza:eza"
    "bat:bat"
    "ripgrep:rg"
    "fd-find:fd"
    "sd:sd"
    "git-delta:delta"
    "atuin:atuin"
  )

  for tool_entry in "${cargo_tools[@]}"; do
    local crate="${tool_entry%%:*}"
    local binary="${tool_entry##*:}"
    if ! command -v "$binary" &>/dev/null; then
      log_info "Installing $crate..."
      run_cmd cargo install "$crate"
    fi
  done
}

remove_stow_conflicts() {
  local component="$1"
  local component_dir="$(dirname "$component")"
  local component_name="$(basename "$component")"

  # Parent directories that should never be removed
  local skip_dirs=(".config" ".local" ".cache")

  # Run stow dry-run to detect conflicts
  local stow_output=$(stow -n --no-folding -v -t "$HOME" -d "$component_dir" "$component_name" 2>&1 || true)

  # Check if there are conflicts
  if echo "$stow_output" | grep -q "existing target"; then
    log_info "Removing conflicts for $component_name..."

    # Extract conflicting file paths and remove them
    echo "$stow_output" | grep "existing target" | while IFS= read -r line; do
      # Extract the filename from the error message
      local conflict=$(echo "$line" | sed -n 's/.*existing target is.*: \(.*\)$/\1/p')
      if [[ -n "$conflict" ]]; then
        # Skip parent directories - they should exist
        local skip=false
        for skip_dir in "${skip_dirs[@]}"; do
          if [[ "$conflict" == "$skip_dir" ]]; then
            skip=true
            break
          fi
        done

        if [[ "$skip" == true ]]; then
          log_info "Skipping parent directory: $conflict"
          continue
        fi

        local full_path="$HOME/$conflict"
        if [[ -e "$full_path" ]] && [[ ! -L "$full_path" ]]; then
          log_warning "Removing conflicting file: $conflict"
          rm -rf "$full_path"
        elif [[ -L "$full_path" ]]; then
          # If it's a symlink, check if it points to our dotfiles
          local link_target=$(readlink "$full_path")
          if [[ "$link_target" != *"dotfiles"* ]]; then
            log_warning "Removing conflicting symlink: $conflict"
            rm -f "$full_path"
          fi
        fi
      fi
    done
  fi
}

stow_configs() {
  log_info "Stowing configurations..."
  cd "$DOTFILES_DIR" || log_error "Failed to cd to $DOTFILES_DIR"

  # Stow each component
  local components=(
    "common/git"
    "shell/common"
    "shell/zsh"
    "shell/bash"
    "shell/starship"
    "terminal/ghostty"
    "editor/nvim"
    "tools/tmux"
    "tools/bat"
    "tools/eza"
    "tools/fzf"
    "tools/lazygit"
    "tools/atuin"
  )

  # Ensure parent directories exist as regular directories
  log_info "Creating parent directories..."
  for dir in ".config" ".local" ".cache"; do
    # Remove anything that's not a directory (file, symlink, broken symlink)
    if [[ ! -d "$HOME/$dir" ]]; then
      if [[ -e "$HOME/$dir" ]] || [[ -L "$HOME/$dir" ]]; then
        log_warning "Removing $dir (not a directory)"
      fi
      rm -rf "$HOME/$dir" 2>/dev/null || true
      mkdir -p "$HOME/$dir"
    fi
  done

  for component in "${components[@]}"; do
    if [[ -d "$component" ]]; then
      log_info "Stowing $component..."

      # Pre-emptively remove known target paths that will be symlinked
      # This handles cases where the user runs --only stow without backup
      cd "$DOTFILES_DIR/$component" || log_error "Failed to cd to $DOTFILES_DIR/$component"

      # Parent directories that should never be removed
      local skip_dirs=(".config" ".local" ".cache")

      find . -type f -o -type d | while IFS= read -r item; do
        # Skip the . directory itself
        [[ "$item" == "." ]] && continue
        # Remove leading ./
        item="${item#./}"

        # Skip parent directories - they should exist as regular directories
        local skip=false
        for skip_dir in "${skip_dirs[@]}"; do
          if [[ "$item" == "$skip_dir" ]]; then
            skip=true
            break
          fi
        done
        if [[ "$skip" == true ]]; then
          continue
        fi

        target_path="$HOME/$item"
        if [[ -e "$target_path" ]] && [[ ! -L "$target_path" ]]; then
          log_info "Removing existing path before stow: $item"
          rm -rf "$target_path"
        fi
      done
      cd "$DOTFILES_DIR" || log_error "Failed to cd back to $DOTFILES_DIR"

      # Remove any remaining conflicts
      remove_stow_conflicts "$component"

      # Now stow the component
      run_cmd stow --no-folding -v -t "$HOME" -d "$(dirname "$component")" "$(basename "$component")"
    fi
  done
}

setup_shell() {
  log_info "Setting up shell..."

  # Change default shell to zsh if not already
  if [[ "$SHELL" != *"zsh"* ]]; then
    if command -v zsh &>/dev/null; then
      log_info "Changing default shell to zsh..."
      run_cmd chsh -s "$(which zsh)"
    fi
  fi

  log_info "Zsh plugins will be auto-installed on first launch via .zshrc"
}

install_nodejs() {
  if [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
    if ! command -v node &>/dev/null; then
      log_info "Installing Node.js v22.x..."

      # Install from NodeSource repository
      run_cmd bash -c "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -"
      run_cmd sudo apt-get install -y nodejs

      log_success "Node.js $(node --version) installed"
    else
      log_info "Node.js $(node --version) already installed, skipping installation"
    fi

    # Configure npm to use Linux-only global prefix (critical for WSL)
    if [[ "$IS_WSL" == true ]] || [[ "$OS_TYPE" == "linux" ]]; then
      log_info "Configuring npm global prefix for Linux..."
      run_cmd npm config set prefix "$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"
    fi

    # Install tree-sitter CLI via Linux npm (not Windows npm in WSL)
    if ! command -v tree-sitter &>/dev/null || [[ "$IS_WSL" == true ]]; then
      log_info "Installing tree-sitter CLI to Linux npm prefix..."

      if command -v npm &>/dev/null; then
        # Force reinstall in WSL to ensure Linux version
        if [[ "$IS_WSL" == true ]]; then
          run_cmd npm uninstall -g tree-sitter-cli 2>/dev/null || true
        fi
        run_cmd npm install -g tree-sitter-cli
        log_success "tree-sitter CLI installed to $HOME/.npm-global/bin"
      else
        log_warning "npm not found, skipping tree-sitter CLI installation"
      fi
    else
      log_info "tree-sitter CLI already installed"
    fi
  elif [[ "$OS_TYPE" == "macos" ]]; then
    log_info "Node.js will be installed via Homebrew"
  fi
}

install_docker() {
  if [[ "$OS_TYPE" == "linux" ]] || [[ "$IS_WSL" == true ]]; then
    if ! command -v docker &>/dev/null; then
      log_info "Installing Docker..."
      # Docker is in apt.txt and will be installed via install_packages
      log_info "Docker will be installed via apt packages"
    else
      log_info "Docker already installed"
    fi

    # Configure Docker to run without sudo
    if ! groups | grep -q docker; then
      log_info "Adding user to docker group..."
      run_cmd sudo usermod -aG docker "$USER"
      log_warning "You need to log out and back in for docker group changes to take effect"
    fi

    # Install zsh Docker completions
    if command -v zsh &>/dev/null; then
      local completion_dir="/usr/share/zsh/vendor-completions"
      if [[ ! -f "$completion_dir/_docker" ]]; then
        log_info "Installing zsh Docker completions..."
        run_cmd sudo mkdir -p "$completion_dir"
        run_cmd sudo curl -fsSL https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker -o "$completion_dir/_docker"
      fi
    fi
  elif [[ "$OS_TYPE" == "macos" ]]; then
    log_info "Docker Desktop will be installed via Homebrew cask"
  fi
}

setup_neovim() {
  log_info "Setting up Neovim..."

  # Install Neovim if not present
  if ! command -v nvim &>/dev/null; then
    log_info "Installing Neovim..."
    if [[ "$OS_TYPE" == "macos" ]]; then
      run_cmd brew install neovim
    else
      # Install from AppImage for latest version
      run_cmd curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
      run_cmd chmod u+x nvim.appimage
      run_cmd sudo mv nvim.appimage /usr/local/bin/nvim
    fi
  else
    log_info "Neovim already installed"
  fi

  # LazyVim config will be stowed from dotfiles
  log_info "LazyVim configuration will be installed via stow"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  --only)
    IFS=',' read -ra COMPONENTS <<<"$2"
    shift 2
    ;;
  --no-docker)
    SKIP_DOCKER=true
    shift
    ;;
  --help)
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
    --dry-run       Preview changes without applying them
    --no-docker     Skip Docker installation
    --only <list>   Install only specified components (comma-separated)
    --help          Show this help message

Components:
    packages, stow, shell, neovim, docker, all

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
  setup_locale

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
    install_nodejs
    install_packages
    stow_configs
    setup_shell
    [[ "$SKIP_DOCKER" == false ]] && install_docker
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
      docker)
        install_docker
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
