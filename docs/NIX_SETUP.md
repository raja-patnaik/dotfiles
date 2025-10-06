# Nix Setup Guide

This guide explains how to use Nix with this dotfiles repository for reproducible development environments.

## Table of Contents

- [What is Nix?](#what-is-nix)
- [Installation](#installation)
- [Using the Flake](#using-the-flake)
- [Home Manager](#home-manager)
- [Direnv Integration](#direnv-integration)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)

## What is Nix?

Nix is a powerful package manager that enables:

- **Reproducible environments**: Same tools, same versions, across all machines
- **Declarative configuration**: Define your environment in code
- **Per-project environments**: Different tool versions for different projects
- **Zero-drift toolchains**: No "works on my machine" problems
- **Atomic upgrades and rollbacks**: Safe to experiment

## Installation

### Automated Installation

The install script can install Nix for you:

```bash
# Install Nix along with other dotfiles
./install.sh

# Or install only Nix
./install.sh --only nix
```

### Manual Installation

#### macOS, Linux, WSL

```bash
# Install Nix with flakes enabled
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes and nix-command
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
```

#### Windows

Nix doesn't run natively on Windows. Use WSL2 instead:

```powershell
# In PowerShell
wsl --install

# Then inside WSL, install Nix using the Linux instructions above
```

### Verify Installation

```bash
nix --version
# Should output: nix (Nix) 2.x.x or higher
```

## Using the Flake

### Enter Development Shell

The easiest way to use the Nix environment:

```bash
cd ~/dotfiles/nix
nix develop
```

This loads all tools defined in `flake.nix`. Your shell will have access to:

- All modern CLI tools (bat, eza, fzf, ripgrep, etc.)
- Development tools (neovim, tmux, etc.)
- Language runtimes (if configured)

### Update Flake Inputs

Keep your Nix packages up to date:

```bash
cd ~/dotfiles/nix
nix flake update
```

### Build and Install Packages

Install all packages from the flake to your profile:

```bash
cd ~/dotfiles/nix
nix profile install .
```

## Home Manager

Home Manager manages your user environment declaratively.

### Install Home Manager

```bash
nix run home-manager/master -- init
```

### Use This Config with Home Manager

Edit `~/dotfiles/nix/home.nix` and replace `username` with your actual username, then:

```bash
cd ~/dotfiles/nix
home-manager switch --flake .#username
```

### Update Home Manager

```bash
home-manager switch --flake ~/dotfiles/nix
```

## Direnv Integration

Direnv + Nix automatically loads project-specific environments.

### Setup

1. **Install direnv** (already in the dotfiles):
   ```bash
   # Should already be installed via dotfiles
   command -v direnv
   ```

2. **Copy the example .envrc**:
   ```bash
   # For a new project
   cp ~/dotfiles/.envrc.example /path/to/project/.envrc
   ```

3. **Edit .envrc** to point to your dotfiles:
   ```bash
   cd /path/to/project
   nano .envrc
   ```

4. **Allow direnv**:
   ```bash
   direnv allow
   ```

### Example .envrc

```bash
# Use the dotfiles Nix flake
use flake ~/dotfiles/nix

# Or for project-specific flake
use flake

# Or load specific packages
use nix --packages nodejs python3 go
```

### How It Works

When you `cd` into a directory with `.envrc`:

1. direnv detects the file
2. Loads the Nix environment from the flake
3. All tools become available in your PATH
4. Exits the environment when you leave the directory

**Benefits:**

- No need to activate virtual environments manually
- Consistent tool versions across team members
- Projects don't pollute your global environment

## Common Tasks

### Add a New Package

Edit `~/dotfiles/nix/flake.nix`:

```nix
devTools = with pkgs; [
  # ... existing packages ...
  your-new-package  # Add here
];
```

Then update:

```bash
cd ~/dotfiles/nix
nix flake update
nix develop  # Or direnv reload
```

### Check What's in the Environment

```bash
# List all packages in the current environment
nix profile list

# Search for a package
nix search nixpkgs package-name
```

### Garbage Collection

Remove old generations and free up space:

```bash
# Delete old generations older than 7 days
nix-collect-garbage --delete-older-than 7d

# Delete all old generations
nix-collect-garbage -d
```

### Pin a Specific Version

In `flake.nix`, you can pin to a specific nixpkgs commit:

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  # Or pin to specific commit:
  # nixpkgs.url = "github:nixos/nixpkgs/abc123def456...";
};
```

## Advanced Usage

### Per-Project Tool Versions

Create a `flake.nix` in your project:

```nix
{
  description = "My Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default =
      let pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs_20  # Specific Node version
          python311  # Specific Python version
        ];
      };
  };
}
```

Then use it with direnv:

```bash
# .envrc
use flake
```

### Integrate with mise/rtx

Nix and mise work together:

```bash
# .envrc
use flake ~/dotfiles/nix  # Base tools from Nix
use mise                  # Project-specific versions from mise
```

### Multiple Environments

You can define multiple dev shells:

```nix
# In flake.nix
outputs = { ... }: {
  devShells.x86_64-linux = {
    default = pkgs.mkShell { ... };
    python = pkgs.mkShell { buildInputs = [ python3 ]; };
    node = pkgs.mkShell { buildInputs = [ nodejs ]; };
  };
};
```

Use them:

```bash
nix develop .#python
nix develop .#node
```

## Troubleshooting

### Flakes are not enabled

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### direnv: error .envrc is blocked

```bash
direnv allow
```

### Nix command not found after installation

Restart your shell or source the Nix profile:

```bash
source ~/.nix-profile/etc/profile.d/nix.sh
```

### Cache is slow

Add Cachix for faster builds:

```bash
# Install cachix
nix-env -iA cachix -f https://cachix.org/api/v1/install

# Use a cache (example: nix-community)
cachix use nix-community
```

### WSL-specific issues

Make sure WSL2 is installed (not WSL1):

```powershell
wsl --set-default-version 2
wsl --list --verbose
```

### Building from source is slow

Nix downloads pre-built binaries when available. If it's building from source:

1. Check your `substituters` in `~/.config/nix/nix.conf`
2. Add official cache:
   ```
   substituters = https://cache.nixos.org
   trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
   ```

### Permission denied errors

If you installed Nix with `--daemon`, ensure the Nix daemon is running:

```bash
# macOS
sudo launchctl start org.nixos.nix-daemon

# Linux with systemd
sudo systemctl start nix-daemon
```

## Resources

- [Nix Documentation](https://nixos.org/manual/nix/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Zero to Nix](https://zero-to-nix.com/) - Excellent tutorial
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive
- [Search Nix Packages](https://search.nixos.org/packages)

## Getting Help

- Nix Discourse: https://discourse.nixos.org/
- Nix Matrix/IRC: #nix on Matrix or Libera.Chat
- Stack Overflow: Tag `nix`

---

**Pro Tip**: Start with `nix develop` in your dotfiles directory to try it out without committing to Home Manager. Once comfortable, switch to Home Manager for full declarative configuration.
