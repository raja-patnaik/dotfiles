# ~/.zshenv - Zsh environment variables
# Loaded for all Zsh sessions (login, interactive, scripts, etc.)

# Ensure XDG directories exist
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Create XDG directories if they don't exist
[[ ! -d "$XDG_CONFIG_HOME" ]] && mkdir -p "$XDG_CONFIG_HOME"
[[ ! -d "$XDG_DATA_HOME" ]] && mkdir -p "$XDG_DATA_HOME"
[[ ! -d "$XDG_STATE_HOME" ]] && mkdir -p "$XDG_STATE_HOME"
[[ ! -d "$XDG_CACHE_HOME" ]] && mkdir -p "$XDG_CACHE_HOME"

# Zsh configuration directory
export ZDOTDIR="${ZDOTDIR:-$HOME}"

# Set default programs
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export BROWSER="${BROWSER:-firefox}"

# Language and locale
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Development paths
export GOPATH="${GOPATH:-$HOME/go}"
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"

# Add common paths to PATH (idempotent)
typeset -U path
path=(
    $HOME/.local/bin
    $HOME/bin
    $CARGO_HOME/bin
    $GOPATH/bin
    $HOME/.npm-global/bin
    /usr/local/bin
    $path
)

# Remove non-existent directories from PATH
path=($^path(N-/))

# Export PATH
export PATH

# Homebrew on Linux/WSL
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# WSL specific settings
if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
    export WSL=1
    export DISPLAY="${DISPLAY:-:0}"
    export BROWSER="wslview"

    # Windows paths in WSL
    export WINDOWS_HOME="/mnt/c/Users/$USER"
fi

# macOS specific settings
if [[ "$OSTYPE" == "darwin"* ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
fi

# Man pages
export MANPATH="/usr/local/man:$MANPATH"

# Less configuration
export LESS="-FXRi"
export LESSHISTFILE="${XDG_CACHE_HOME}/less/history"

# Docker
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"

# Node.js
export NODE_REPL_HISTORY="${XDG_DATA_HOME}/node_repl_history"
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"

# Python
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"
export PYTHONUSERBASE="${XDG_DATA_HOME}/python"
export PYTHON_HISTORY="${XDG_STATE_HOME}/python/history"
export PIPENV_VENV_IN_PROJECT=1

# Rust
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

# SSH
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"