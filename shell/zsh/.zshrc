# ~/.zshrc - Zsh configuration

# Source shared shell configuration
[[ -f ~/.config/shell/shell_common.sh ]] && source ~/.config/shell/shell_common.sh

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
# Plugin Management
# ============================================================================

plugins_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

load_plugin() {
    local plugin_name="$1"
    local plugin_file="$2"
    local plugin_path="$plugins_dir/$plugin_name/$plugin_file"
    [[ -f "$plugin_path" ]] && source "$plugin_path"
}

ensure_plugin() {
    local repo="$1"
    local name="$(basename $repo)"
    [[ ! -d "$plugins_dir/$name" ]] && git clone --depth=1 "https://github.com/$repo" "$plugins_dir/$name"
}

ensure_plugin "zsh-users/zsh-autosuggestions"
ensure_plugin "zsh-users/zsh-syntax-highlighting"
ensure_plugin "zsh-users/zsh-completions"
ensure_plugin "agkozak/zsh-z"

load_plugin "zsh-autosuggestions" "zsh-autosuggestions.zsh"
load_plugin "zsh-syntax-highlighting" "zsh-syntax-highlighting.zsh"
load_plugin "zsh-z" "zsh-z.plugin.zsh"

fpath=("$plugins_dir/zsh-completions/src" $fpath)

# ============================================================================
# Completion System
# ============================================================================

autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
    compinit
else
    compinit -C
fi

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

bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ============================================================================
# FZF
# ============================================================================

[[ -f ~/.config/fzf/fzf.zsh ]] && source ~/.config/fzf/fzf.zsh

# ============================================================================
# Starship Prompt
# ============================================================================

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Zsh-specific aliases
alias reload='exec zsh'

# ============================================================================
# Local Configuration
# ============================================================================

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
