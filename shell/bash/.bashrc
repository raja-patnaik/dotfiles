# ~/.bashrc - Bash configuration

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source shared shell configuration
[[ -f ~/.config/shell/shell_common.sh ]] && source ~/.config/shell/shell_common.sh

# ============================================================================
# History
# ============================================================================

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
HISTFILE="$HOME/.bash_history"

shopt -s histappend
shopt -s cmdhist
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# ============================================================================
# Shell Options
# ============================================================================

shopt -s checkwinsize
shopt -s cdspell
shopt -s extglob
shopt -s dotglob
shopt -s globstar 2>/dev/null
shopt -s nocaseglob

# ============================================================================
# Completion
# ============================================================================

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
# FZF
# ============================================================================

[[ -f ~/.config/fzf/fzf.bash ]] && source ~/.config/fzf/fzf.bash

# ============================================================================
# Starship Prompt
# ============================================================================

if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# Bash-specific aliases
alias reload='source ~/.bashrc'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ============================================================================
# Local Configuration
# ============================================================================

[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
