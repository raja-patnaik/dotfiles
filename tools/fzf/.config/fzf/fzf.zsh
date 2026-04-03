# FZF Configuration for Zsh

# Source shared config
[[ -f ~/.config/fzf/fzf_common.sh ]] && source ~/.config/fzf/fzf_common.sh

# Source fzf key bindings and completion
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
fi
