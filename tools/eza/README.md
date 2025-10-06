# Eza Configuration

Eza is a modern replacement for `ls` with better defaults and additional features.

## Setup

To use the configuration file, set the environment variable in your shell:

### Zsh/Bash
```bash
export EZA_CONFIG_FILE="$HOME/.config/eza/config"
```

### PowerShell
```powershell
$env:EZA_CONFIG_FILE = "$HOME\.config\eza\config"
```

## Recommended Aliases

These are already configured in `.zshrc` but here for reference:

```bash
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias l='eza -lah --icons --group-directories-first'
```

## Common Usage

```bash
# List with details
eza -l

# Show all files including hidden
eza -a

# Tree view
eza --tree

# With git status
eza --git

# Only directories
eza -D

# Sort by size
eza -l --sort=size

# Sort by modified time
eza -l --sort=modified

# Reverse sort
eza -l --reverse

# Show file sizes in human-readable format
eza -lh
```

## Color Customization

Eza uses LS_COLORS environment variable. You can customize colors using:

```bash
export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"
```

Or use a tool like `vivid`:
```bash
export LS_COLORS="$(vivid generate molokai)"
```
