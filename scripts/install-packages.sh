#!/usr/bin/env bash
# Package installation script
# Installs packages based on detected OS and package manager

set -euo pipefail

# Source OS detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect-os.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Install with APT
install_apt() {
    local packages_file="$1"
    if [[ ! -f "$packages_file" ]]; then
        log_warning "Package file not found: $packages_file"
        return
    fi

    log_info "Installing packages with APT..."
    sudo apt-get update

    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip comments and empty lines
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue

        log_info "Installing: $package"
        sudo apt-get install -y "$package" || log_warning "Failed to install: $package"
    done < "$packages_file"
}

# Install with YUM/DNF
install_yum() {
    local packages_file="$1"
    if [[ ! -f "$packages_file" ]]; then
        log_warning "Package file not found: $packages_file"
        return
    fi

    log_info "Installing packages with YUM/DNF..."

    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip comments and empty lines
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue

        log_info "Installing: $package"
        sudo yum install -y "$package" || sudo dnf install -y "$package" || log_warning "Failed to install: $package"
    done < "$packages_file"
}

# Install with Homebrew
install_brew() {
    local packages_file="$1"

    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if [[ -f "${packages_file%.txt}" ]]; then
        # Brewfile exists
        log_info "Installing packages with Brewfile..."
        brew bundle --file="${packages_file%.txt}"
    elif [[ -f "$packages_file" ]]; then
        # Text file with package list
        log_info "Installing packages with Homebrew..."
        while IFS= read -r package || [[ -n "$package" ]]; do
            # Skip comments and empty lines
            [[ "$package" =~ ^#.*$ ]] && continue
            [[ -z "$package" ]] && continue

            log_info "Installing: $package"
            brew install "$package" || log_warning "Failed to install: $package"
        done < "$packages_file"
    else
        log_warning "Package file not found: $packages_file"
    fi
}

# Install with Pacman
install_pacman() {
    local packages_file="$1"
    if [[ ! -f "$packages_file" ]]; then
        log_warning "Package file not found: $packages_file"
        return
    fi

    log_info "Installing packages with Pacman..."

    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip comments and empty lines
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue

        log_info "Installing: $package"
        sudo pacman -S --noconfirm "$package" || log_warning "Failed to install: $package"
    done < "$packages_file"
}

# Install with Scoop (Windows)
install_scoop() {
    local packages_file="$1"
    if [[ ! -f "$packages_file" ]]; then
        log_warning "Package file not found: $packages_file"
        return
    fi

    # Check if Scoop is installed
    if ! command -v scoop &>/dev/null; then
        log_info "Installing Scoop..."
        powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
        powershell -Command "irm get.scoop.sh | iex"
    fi

    log_info "Installing packages with Scoop..."

    # Add buckets
    scoop bucket add extras
    scoop bucket add nerd-fonts

    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip comments and empty lines
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue

        log_info "Installing: $package"
        scoop install "$package" || log_warning "Failed to install: $package"
    done < "$packages_file"
}

# Install with WinGet (Windows)
install_winget() {
    local packages_file="$1"
    if [[ ! -f "$packages_file" ]]; then
        log_warning "Package file not found: $packages_file"
        return
    fi

    log_info "Installing packages with WinGet..."

    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip comments and empty lines
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue

        log_info "Installing: $package"
        winget install --id "$package" --accept-package-agreements --accept-source-agreements || log_warning "Failed to install: $package"
    done < "$packages_file"
}

# Install Rust toolchain
install_rust() {
    if ! command -v rustc &>/dev/null; then
        log_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        log_info "Rust already installed"
    fi

    # Install common Rust tools
    log_info "Installing Rust tools..."
    cargo install --locked \
        zoxide \
        eza \
        bat \
        ripgrep \
        fd-find \
        sd \
        git-delta \
        atuin \
        cargo-update
}

# Install Node.js tools
install_node_tools() {
    if ! command -v node &>/dev/null; then
        log_warning "Node.js is not installed"
        return
    fi

    log_info "Installing Node.js global packages..."
    npm install -g \
        pnpm \
        yarn \
        npm-check-updates \
        prettier \
        eslint \
        typescript \
        tsx \
        nodemon
}

# Install Python tools
install_python_tools() {
    if ! command -v python3 &>/dev/null; then
        log_warning "Python 3 is not installed"
        return
    fi

    log_info "Installing Python tools..."
    pip3 install --user --upgrade \
        pip \
        setuptools \
        wheel \
        pipx \
        black \
        ruff \
        mypy \
        pytest \
        ipython \
        jupyter
}

# Main installation function
main() {
    local packages_dir="${1:-$SCRIPT_DIR/../packages}"
    local os_type="${2:-$(detect_os | jq -r '.os')}"
    local pm="${3:-$(get_package_manager)}"

    log_info "OS: $os_type"
    log_info "Package Manager: $pm"
    log_info "Packages Directory: $packages_dir"

    case "$pm" in
        apt)
            install_apt "$packages_dir/apt.txt"
            ;;
        yum|dnf)
            install_yum "$packages_dir/yum.txt"
            ;;
        brew)
            if [[ "$os_type" == "macos" ]]; then
                install_brew "$packages_dir/Brewfile"
            else
                install_brew "$packages_dir/brew-linux.txt"
            fi
            ;;
        pacman)
            install_pacman "$packages_dir/pacman.txt"
            ;;
        scoop)
            install_scoop "$packages_dir/scoop.txt"
            ;;
        winget)
            install_winget "$packages_dir/winget.txt"
            ;;
        *)
            log_error "Unsupported package manager: $pm"
            ;;
    esac

    # Install language-specific tools
    log_info "Installing language-specific tools..."
    install_rust
    install_node_tools
    install_python_tools

    log_success "Package installation completed!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi