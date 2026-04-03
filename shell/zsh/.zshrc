# ~/.zshrc - Zsh configuration
# Optimized for performance with lazy loading

# ============================================================================
# Environment Variables
# ============================================================================

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Path configuration
# npm global binaries (for WSL/Linux, ensures npm packages use Linux binaries)
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# ============================================================================
# Zsh Options
# ============================================================================

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
setopt HIST_VERIFY               # Do not execute immediately upon history expansion.

# Directory navigation
setopt AUTO_CD                   # Auto change to a directory without typing cd.
setopt AUTO_PUSHD                # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS         # Do not store duplicates in the stack.
setopt PUSHD_SILENT              # Do not print the directory stack after pushd or popd.

# Completion
setopt ALWAYS_TO_END             # Move cursor to the end of a completed word.
setopt AUTO_LIST                 # Automatically list choices on ambiguous completion.
setopt AUTO_MENU                 # Show completion menu on a successive tab press.
setopt COMPLETE_IN_WORD          # Complete from both ends of a word.
setopt PATH_DIRS                 # Perform path search even on command names with slashes.

# ============================================================================
# Plugin Management (using native zsh)
# ============================================================================

# Load plugins conditionally
plugins_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

# Function to load plugin
load_plugin() {
    local plugin_name="$1"
    local plugin_file="$2"
    local plugin_path="$plugins_dir/$plugin_name/$plugin_file"

    if [[ -f "$plugin_path" ]]; then
        source "$plugin_path"
    fi
}

# Clone plugin if not exists
ensure_plugin() {
    local repo="$1"
    local name="$(basename $repo)"

    if [[ ! -d "$plugins_dir/$name" ]]; then
        git clone --depth=1 "https://github.com/$repo" "$plugins_dir/$name"
    fi
}

# Ensure essential plugins are installed
ensure_plugin "zsh-users/zsh-autosuggestions"
ensure_plugin "zsh-users/zsh-syntax-highlighting"
ensure_plugin "zsh-users/zsh-completions"
ensure_plugin "agkozak/zsh-z"

# Load plugins
load_plugin "zsh-autosuggestions" "zsh-autosuggestions.zsh"
load_plugin "zsh-syntax-highlighting" "zsh-syntax-highlighting.zsh"
load_plugin "zsh-z" "zsh-z.plugin.zsh"

# Add completions to fpath
fpath=("$plugins_dir/zsh-completions/src" $fpath)

# ============================================================================
# Completion System
# ============================================================================

# Initialize completion system
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'

# ============================================================================
# Key Bindings
# ============================================================================

# Use emacs keybindings
bindkey -e

# History search with arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Edit command in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ============================================================================
# FZF Configuration
# ============================================================================

# Load fzf configuration from separate file
[[ -f ~/.config/fzf/fzf.zsh ]] && source ~/.config/fzf/fzf.zsh

# ============================================================================
# Tool Initialization
# ============================================================================

# Starship prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Zoxide (better cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Atuin (shell history sync)
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi

# direnv
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# mise (formerly rtx)
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

# ============================================================================
# Aliases
# ============================================================================

# Core utilities
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias ps='procs'
alias top='btm'
alias du='dust'
alias df='duf'
alias sed='sd'
alias curl='xh'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log --oneline --graph --decorate'
alias lg='lazygit'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Tmux
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'

# Docker
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'

# System
alias reload='exec zsh'
alias path='echo -e ${PATH//:/\\n}'

# ============================================================================
# Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$@" && cd "$@"
}

# Extract archives
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.tar.xz) tar xJf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) unrar e $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup
backup() {
    cp "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)"
}

# Git commit with message
gcm() {
    git commit -m "$*"
}

# fzf git branch selector
fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fzf process killer
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# ============================================================================
# Local Configuration
# ============================================================================

# Source local configuration if exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ============================================================================
# Performance Profiling (comment out when not needed)
# ============================================================================

# zprof  # Uncomment to see startup time breakdown