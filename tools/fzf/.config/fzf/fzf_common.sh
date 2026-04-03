# FZF shared configuration for bash and zsh

if ! command -v fzf >/dev/null 2>&1; then
    return
fi

# Use fd for finding files (respects .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'

# Default options with preview and Tokyo Night colors
export FZF_DEFAULT_OPTS="
    --height 60%
    --layout=reverse
    --border=rounded
    --inline-info
    --preview 'bat --color=always --style=header,grid --line-range :300 {}'
    --preview-window=right:50%:wrap
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-u:preview-page-up'
    --bind='ctrl-d:preview-page-down'
    --bind='ctrl-a:select-all'
    --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7
    --color=fg+:#c0caf5,bg+:#283457,hl+:#7dcfff
    --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
    --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
"

# CTRL-T: file search
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :300 {}'"

# ALT-C: directory search
export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"

# CTRL-R: history search
export FZF_CTRL_R_OPTS="
    --preview 'echo {}'
    --preview-window=down:3:wrap
    --color header:italic
"

# --- Functions ---

# Search and edit file
fe() {
    local file
    file=$(fzf --query="$1" --select-1 --exit-0)
    [[ -n "$file" ]] && ${EDITOR:-nvim} "$file"
}

# cd to subdirectory
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git | fzf --query="$1" --select-1 --exit-0)
    [[ -n "$dir" ]] && cd "$dir"
}

# Search text in files with ripgrep, open in editor
frg() {
    local result
    result=$(rg --line-number --no-heading --color=always --smart-case "$@" |
        fzf --ansi \
            --delimiter ':' \
            --preview 'bat --color=always --highlight-line {2} {1}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
    if [[ -n "$result" ]]; then
        local file line
        file=$(echo "$result" | cut -d: -f1)
        line=$(echo "$result" | cut -d: -f2)
        ${EDITOR:-nvim} "+$line" "$file"
    fi
}

# Git branch selector
fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Process killer
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    [[ -n "$pid" ]] && echo "$pid" | xargs kill -${1:-9}
}
