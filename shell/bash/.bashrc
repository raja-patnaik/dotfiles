# ~/.bashrc - Bash configuration
# For interactive non-login shells

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================================================
# History Configuration
# ============================================================================

HISTCONTROL=ignoreboth:erasedups  # Don't save duplicates
HISTSIZE=10000                    # History lines in memory
HISTFILESIZE=20000                 # History lines on disk
HISTFILE="$HOME/.bash_history"

# Append to history, don't overwrite
shopt -s histappend

# Save multi-line commands as single history entry
shopt -s cmdhist

# Update history immediately
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# ============================================================================
# Shell Options
# ============================================================================

# Check window size after each command
shopt -s checkwinsize

# Correct minor cd errors
shopt -s cdspell

# Extended pattern matching
shopt -s extglob

# Include hidden files in pathname expansion
shopt -s dotglob

# Enable ** for recursive globbing
shopt -s globstar 2> /dev/null

# Case-insensitive pathname expansion
shopt -s nocaseglob

# ============================================================================
# Completion
# ============================================================================

# Enable programmable completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    elif [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
        . /opt/homebrew/etc/profile.d/bash_completion.sh
    fi
fi

# ============================================================================
# Environment Variables
# ============================================================================

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export LESS='-FXRi'

# XDG directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Path
# npm global binaries (for WSL/Linux, ensures npm packages use Linux binaries)
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# ============================================================================
# Prompt
# ============================================================================

# Simple prompt if Starship is not available
if ! command -v starship &> /dev/null; then
    # Color definitions
    RED='\[\033[0;31m\]'
    GREEN='\[\033[0;32m\]'
    YELLOW='\[\033[0;33m\]'
    BLUE='\[\033[0;34m\]'
    PURPLE='\[\033[0;35m\]'
    CYAN='\[\033[0;36m\]'
    WHITE='\[\033[0;37m\]'
    RESET='\[\033[0m\]'

    # Git branch in prompt
    git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    }

    # Set prompt
    PS1="${BLUE}\u${WHITE}@${GREEN}\h ${CYAN}\w${YELLOW}\$(git_branch)${RESET}\n$ "
fi

# ============================================================================
# Aliases
# ============================================================================

# Core utilities
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
fi

if command -v bat &> /dev/null; then
    alias cat='bat'
fi

if command -v rg &> /dev/null; then
    alias grep='rg'
else
    alias grep='grep --color=auto'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
fi

# Editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Tmux
alias t='tmux'
alias ta='tmux attach'
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'

# System
alias reload='source ~/.bashrc'
alias path='echo -e ${PATH//:/\\n}'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

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
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.tar.xz)    tar xJf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup
backup() {
    cp "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)"
}

# ============================================================================
# Tool Initialization
# ============================================================================

# FZF
if command -v fzf &> /dev/null; then
    # Source fzf key bindings
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash

    # FZF options
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border=rounded"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# Zoxide (better cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# Atuin (shell history sync)
if command -v atuin &> /dev/null; then
    eval "$(atuin init bash)"
fi

# ============================================================================
# Local Configuration
# ============================================================================

# Source local configuration if exists
[ -f ~/.bashrc.local ] && source ~/.bashrc.local