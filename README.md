# Cross-Platform Dotfiles

A comprehensive, modular dotfiles repository that works seamlessly across **macOS**, **Linux**, and **WSL**. This setup provides a consistent development environment with modern tools, optimized configurations, and automated installation.

## Features

- **Cross-platform compatibility**: Works on macOS, Linux, and WSL
- **Modular structure**: Install only what you need
- **Automated installation**: Single command setup with intelligent OS detection
- **Modern tools**: Cutting-edge CLI tools for enhanced productivity
- **Symlink management**: GNU Stow for consistent config linking
- **Backup system**: Automatic backup of existing configs before installation

## Tech Stack

### Core Tools

- **Terminal**: [Ghostty](https://ghostty.org/) - Fast, native terminal emulator
- **Shell**: [Zsh](https://www.zsh.org/) with optimized configuration
- **Prompt**: [Starship](https://starship.rs/) - Minimal, blazing-fast prompt
- **Multiplexer**: [tmux](https://github.com/tmux/tmux) - Terminal session management
- **Editor**: [Neovim](https://neovim.io/) + [LazyVim](https://www.lazyvim.org/) - Modern IDE experience

### CLI Enhancements

- **fzf**: Fuzzy finder for everything
- **ripgrep** (`rg`): Lightning-fast recursive search
- **fd**: User-friendly alternative to `find`
- **zoxide** (`z`): Smarter `cd` command with frecency
- **eza**: Modern replacement for `ls` with icons
- **bat**: `cat` with syntax highlighting and Git integration
- **delta**: Beautiful diffs for Git
- **sd**: Intuitive find & replace (better than `sed`)
- **jq/yq**: JSON/YAML processing
- **xh**: User-friendly HTTP requests
- **tldr**: Simplified man pages

### System Monitoring

- **procs**: Modern process viewer (ps replacement)
- **bottom** (`btm`): Cross-platform system monitor
- **dust**: Intuitive disk usage analyzer (du replacement)
- **duf**: Pretty disk usage viewer (df replacement)
- **hyperfine**: Command-line benchmarking tool
- **tokei**: Code statistics and line counter

### Development Tools

- **mise**: Tool version management
- **direnv**: Per-directory environment variables
- **just**: Command runner for project tasks
- **lazygit**: Terminal UI for Git
- **atuin**: Sync shell history across machines
- **gh**: GitHub CLI
- **git-absorb**: Automatic fixup commits
- **pre-commit**: Git hooks for code quality

## Directory Structure

```
dotfiles/
├── install.sh           # Installer (macOS/Linux/WSL)
├── scripts/             # Helper scripts
├── packages/            # OS-specific package lists
├── common/              # Cross-platform configs (git, mise, etc.)
├── terminal/            # Terminal emulator configs (ghostty)
├── shell/               # Shell configurations (zsh, bash, starship)
├── editor/              # Editor configs (neovim)
├── tools/               # CLI tool configurations
│   ├── bat/             # bat (cat replacement) config
│   ├── eza/             # eza (ls replacement) config
│   ├── fzf/             # fzf fuzzy finder config
│   ├── tmux/            # tmux config
│   ├── lazygit/         # lazygit config
│   ├── atuin/           # atuin history config
│   └── direnv/          # direnv config
├── development/         # Development tool configs
│   ├── just/            # justfile for task running
│   └── pre-commit/      # pre-commit hooks
└── os-specific/         # OS-specific configurations
```

## Quick Start

### Prerequisites

- **Git** (for cloning the repo)
- **curl** or **wget** (for downloading installers)
- **sudo** access (for Linux/macOS)

### One-Line Installation

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh
```

### Manual Installation

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. **Run the installer**

```bash
./install.sh
```

## Installation Options

### Selective Installation

Install only specific components:

```bash
./install.sh --only packages,shell,neovim
```

Available components:
- `packages` - Install system packages
- `stow`/`links` - Create configuration symlinks
- `shell` - Setup shell environment
- `neovim` - Configure Neovim
- `wsl` - WSL-specific setup

### Dry Run

Preview changes without applying them:

```bash
./install.sh --dry-run
```

## Package Management

### Adding New Packages

1. Edit the appropriate package file in `packages/`:
   - `Brewfile` - macOS Homebrew packages
   - `brew-linux.txt` - Linux Homebrew packages
   - `apt.txt` - Ubuntu/Debian packages

2. Run the appropriate update command:

### Updating All Packages

```bash
brew upgrade            # macOS/Linux
sudo apt upgrade        # Ubuntu/WSL
```

## Configuration

### Personal Settings

Create local configuration files that won't be tracked by Git:

```bash
# Git user configuration
cat > ~/.gitconfig.local <<EOF
[user]
    name = Your Name
    email = your.email@example.com
EOF

# Shell-specific local settings
touch ~/.zshrc.local
touch ~/.bashrc.local
```

### Environment Variables

Set custom environment variables in:
- `~/.zshenv` - Zsh environment (loaded for all shells)
- `~/.bashrc` - Bash environment

## Common Tasks

### Managing Configurations

**Add a new configuration:**
1. Place the config file in the appropriate directory
2. Update the installer script to include it
3. Run `./install.sh` to apply

**Update configurations:**
```bash
cd ~/dotfiles
git pull
./install.sh
```

## Customization

### Theme

The default theme is **Tokyo Night**. To change it:

1. **Terminal** - Edit Ghostty config in `~/.config/ghostty/config`

2. **Neovim** - Edit `~/.config/nvim/lua/config/lazy.lua`:
```lua
colorscheme = "catppuccin"  -- or any other theme
```

3. **Tmux** - Edit `~/.tmux.conf` status bar colors

### Key Bindings

- **tmux prefix**: `Ctrl-a` (like GNU Screen)
- **Neovim leader**: `Space`

## Troubleshooting

### Common Issues

**Command not found after installation:**
- Restart your shell: `exec $SHELL`
- Or source the config: `source ~/.zshrc`

**Permission denied errors:**
- Ensure you have sudo access on Unix systems

**WSL-specific issues:**
- Make sure WSL2 is installed and updated
- Use the Linux installers within WSL

## License

MIT License - See [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgments

- [LazyVim](https://www.lazyvim.org/) for the Neovim configuration
- [GNU Stow](https://www.gnu.org/software/stow/) for symlink management
- All the amazing open-source tool maintainers
