# FZF Configuration for Bash

# Source shared config
[[ -f ~/.config/fzf/fzf_common.sh ]] && source ~/.config/fzf/fzf_common.sh

# Source fzf key bindings and completion
if [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
    source /usr/share/doc/fzf/examples/completion.bash
fi
