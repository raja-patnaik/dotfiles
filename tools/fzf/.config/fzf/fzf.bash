# FZF Configuration for Bash
# Source this file from .bashrc: source ~/.config/fzf/fzf.bash

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
    return
fi

# Source fzf key bindings and completion if available
if [[ -f ~/.fzf.bash ]]; then
    source ~/.fzf.bash
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
    source /usr/share/doc/fzf/examples/completion.bash
fi

# Use fd for finding files
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'

# FZF default options
export FZF_DEFAULT_OPTS="
    --height 60%
    --layout=reverse
    --border=rounded
    --inline-info
    --preview 'bat --color=always --style=header,grid --line-range :300 {}'
    --preview-window=right:50%:wrap
    --bind='ctrl-/:toggle-preview'
    --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
    --color=fg+:#c0caf5,bg+:#283457,hl+:#7dcfff
"

# CTRL-T options
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :300 {}'"

# ALT-C options
export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
