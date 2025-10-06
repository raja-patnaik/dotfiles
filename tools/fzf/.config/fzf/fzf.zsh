# FZF Configuration for Zsh
# Source this file from .zshrc: source ~/.config/fzf/fzf.zsh

# Check if fzf is installed
if ! command -v fzf >/dev/null 2>&1; then
    return
fi

# ============================================================================
# FZF Auto-completion and Key Bindings
# ============================================================================

# Source fzf key bindings and completion if available
if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
fi

# ============================================================================
# FZF Default Options
# ============================================================================

# Use fd for finding files (faster than find and respects .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'

# FZF default options with preview
export FZF_DEFAULT_OPTS="
    --height 60%
    --layout=reverse
    --border=rounded
    --inline-info
    --preview 'bat --color=always --style=header,grid --line-range :300 {}'
    --preview-window=right:50%:wrap
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-y:execute-silent(echo {} | pbcopy)'
    --bind='ctrl-e:execute(echo {} | xargs -o nvim)'
    --bind='ctrl-u:preview-page-up'
    --bind='ctrl-d:preview-page-down'
    --bind='ctrl-a:select-all'
    --bind='ctrl-r:toggle-all'
    --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
    --color=fg+:#c0caf5,bg+:#283457,hl+:#7dcfff
    --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
    --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
"

# ============================================================================
# FZF CTRL-T Options (File Search)
# ============================================================================

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
    --preview 'bat --color=always --style=header,grid --line-range :300 {}'
    --preview-window=right:60%:wrap
    --bind='ctrl-/:toggle-preview'
    --header='CTRL-T: Select file | CTRL-/: Toggle preview'
"

# ============================================================================
# FZF ALT-C Options (Directory Search)
# ============================================================================

export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="
    --preview 'eza --tree --level=2 --color=always {} | head -200'
    --preview-window=right:60%:wrap
    --bind='ctrl-/:toggle-preview'
    --header='ALT-C: Change directory | CTRL-/: Toggle preview'
"

# ============================================================================
# FZF CTRL-R Options (History Search)
# ============================================================================

export FZF_CTRL_R_OPTS="
    --preview 'echo {}'
    --preview-window=down:3:wrap
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --header='CTRL-R: Search history | CTRL-Y: Copy to clipboard'
    --color header:italic
"

# ============================================================================
# Custom FZF Functions
# ============================================================================

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
    if [[ "$OSTYPE" == "darwin"* ]]; then
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi

    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}

# fzf docker container selector
fdc() {
    local container
    container=$(docker ps -a | sed 1d | fzf | awk '{print $1}')
    if [[ -n "$container" ]]; then
        docker exec -it "$container" bash
    fi
}

# fzf cd to git repository
fgr() {
    local repo
    repo=$(ghq list | fzf --preview "eza --tree --level=1 --color=always $(ghq root)/{}")
    if [[ -n "$repo" ]]; then
        cd "$(ghq root)/$repo" || return
    fi
}

# fzf search and edit file
fe() {
    local file
    file=$(fzf --query="$1" --select-1 --exit-0)
    if [[ -n "$file" ]]; then
        ${EDITOR:-nvim} "$file"
    fi
}

# fzf cd to subdirectory
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git | fzf --query="$1" --select-1 --exit-0)
    if [[ -n "$dir" ]]; then
        cd "$dir" || return
    fi
}

# fzf search history and execute
fh() {
    eval $(history | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fzf search for text in files using ripgrep
frg() {
    local result
    result=$(rg --line-number --no-heading --color=always --smart-case "$@" |
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter ':' \
            --preview 'bat --color=always --highlight-line {2} {1}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')

    if [[ -n "$result" ]]; then
        local file=$(echo "$result" | cut -d: -f1)
        local line=$(echo "$result" | cut -d: -f2)
        ${EDITOR:-nvim} "+$line" "$file"
    fi
}

# ============================================================================
# Aliases
# ============================================================================

# Preview file with fzf
alias fp='fzf --preview "bat --color=always --style=header,grid --line-range :500 {}"'

# Search in files with preview
alias rgi='rg --line-number --no-heading --color=always --smart-case . | fzf --ansi --preview "bat --color=always --highlight-line {2} {1}"'
