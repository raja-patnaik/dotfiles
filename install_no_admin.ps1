# PowerShell installation script for Windows WITHOUT Administrator Rights
# This script installs dotfiles and tools without requiring admin privileges
# All installations are user-scoped and files are copied instead of symlinked

param(
    [switch]$DryRun,
    [string[]]$Only,
    [switch]$UpdateConfigs,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Info { Write-ColorOutput "[INFO] $args" "Cyan" }
function Write-Success { Write-ColorOutput "[SUCCESS] $args" "Green" }
function Write-Warning { Write-ColorOutput "[WARNING] $args" "Yellow" }
function Write-Error { Write-ColorOutput "[ERROR] $args" "Red"; exit 1 }

# Configuration
$DotfilesDir = $PSScriptRoot
$BackupDir = "$env:USERPROFILE\.dotfiles-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$IsWSL = $false

# Show help
if ($Help) {
    @"
========================================
   NO-ADMIN Dotfiles Installation
========================================

This script installs dotfiles WITHOUT requiring administrator privileges.

Usage: .\install_no_admin.ps1 [OPTIONS]

Options:
    -DryRun         Preview changes without applying them
    -Only <list>    Install only specified components (comma-separated)
    -UpdateConfigs  Update config files from dotfiles (when files were copied)
    -Help           Show this help message

Components:
    packages    - Install packages via Scoop and WinGet (user-scoped)
    configs     - Copy configuration files to appropriate locations
    shell       - Setup PowerShell with user-scoped modules
    neovim      - Configure Neovim with LazyVim
    all         - Install everything (default)

Examples:
    .\install_no_admin.ps1
    .\install_no_admin.ps1 -Only packages,shell
    .\install_no_admin.ps1 -DryRun
    .\install_no_admin.ps1 -UpdateConfigs

Key Differences from Admin Installation:
    - Uses Scoop instead of Chocolatey (no admin required)
    - WinGet packages installed with --scope user
    - Config files are COPIED (not symlinked)
    - PowerShell modules use -Scope CurrentUser
    - All tools install to user directories

Limitations:
    - Config changes require running with -UpdateConfigs to sync
    - Some tools may not be available via Scoop
    - Cannot modify system-wide settings

"@
    exit 0
}

function Test-CommandExists {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-WSL {
    if (Test-CommandExists wsl) {
        $wslStatus = wsl --status 2>$null
        return $?
    }
    return $false
}

function Install-Scoop {
    if (-not (Test-CommandExists scoop)) {
        Write-Info "Installing Scoop (user-scoped package manager)..."
        if (-not $DryRun) {
            # Scoop doesn't require admin and installs to ~\scoop
            try {
                Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

                # Add useful buckets
                Write-Info "Adding Scoop buckets..."
                scoop bucket add extras
                scoop bucket add nerd-fonts

                Write-Success "Scoop installed successfully to $env:USERPROFILE\scoop"
            } catch {
                Write-Error "Failed to install Scoop`: ${_}"
            }
        }
    } else {
        Write-Info "Scoop already installed"
        # Ensure buckets are added (silently ignore if they already exist)
        if (-not $DryRun) {
            try {
                scoop bucket add extras 2>&1 | Out-Null
                Write-Info "Added extras bucket"
            } catch {
                # Bucket already exists, ignore
            }
            try {
                scoop bucket add nerd-fonts 2>&1 | Out-Null
                Write-Info "Added nerd-fonts bucket"
            } catch {
                # Bucket already exists, ignore
            }
        }
    }
}

function Install-Winget {
    if (-not (Test-CommandExists winget)) {
        Write-Warning "WinGet is not installed. It comes pre-installed with Windows 11 and recent Windows 10 updates."
        Write-Info "To install WinGet manually, visit: https://aka.ms/getwinget"
        Write-Info "Continuing without WinGet..."
    } else {
        Write-Info "WinGet is available"
    }
}

function Backup-ExistingConfigs {
    Write-Info "Backing up existing configurations to $BackupDir..."

    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

        $configs = @(
            "$env:USERPROFILE\.gitconfig",
            "$env:USERPROFILE\.wezterm.lua",
            "$env:USERPROFILE\.config\starship.toml",
            "$env:USERPROFILE\.config\nvim",
            "$env:LOCALAPPDATA\nvim",
            "$env:APPDATA\lazygit",
            "$env:USERPROFILE\.config\atuin",
            "$env:USERPROFILE\.config\bat",
            "$env:USERPROFILE\.config\direnv",
            "$env:USERPROFILE\.ezarc"
        )

        foreach ($config in $configs) {
            if (Test-Path $config) {
                $relativePath = $config.Replace($env:USERPROFILE, "").TrimStart("\")
                $backupPath = Join-Path $BackupDir $relativePath
                $backupParent = Split-Path $backupPath -Parent
                New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
                Copy-Item -Path $config -Destination $backupPath -Recurse -Force
                Remove-Item -Path $config -Recurse -Force
                Write-Info "Backed up $config"
            }
        }
    }
}

function Install-Packages {
    Write-Info "Installing packages (this may take a while)..."

    # Scoop packages (primary package manager for no-admin)
    $scoopPackagesFile = Join-Path $DotfilesDir "packages\scoop.txt"
    if ((Test-Path $scoopPackagesFile) -and (Test-CommandExists scoop)) {
        Write-Info "Installing Scoop packages..."
        $packages = Get-Content $scoopPackagesFile | Where-Object { $_ -and $_ -notmatch "^\s*#" }
        foreach ($package in $packages) {
            if (-not $DryRun) {
                # Check if already installed
                $installed = scoop list | Select-String -Pattern "^\s*$package\s"
                if (-not $installed) {
                    Write-Info "Installing $package..."
                    try {
                        scoop install $package
                    } catch {
                        Write-Warning "Failed to install ${package} via Scoop`: ${_}"
                    }
                } else {
                    Write-Info "$package already installed"
                }
            } else {
                Write-Info "[DRY RUN] Would install: $package"
            }
        }
    }

    # WinGet packages (with user scope)
    $wingetPackagesFile = Join-Path $DotfilesDir "packages\winget.txt"
    if ((Test-Path $wingetPackagesFile) -and (Test-CommandExists winget)) {
        Write-Info "Installing WinGet packages (user-scoped)..."
        $packages = Get-Content $wingetPackagesFile | Where-Object { $_ -and $_ -notmatch "^\s*#" }
        foreach ($package in $packages) {
            if (-not $DryRun) {
                Write-Info "Installing $package..."
                try {
                    # Use --scope user to install without admin rights
                    winget install --id $package --scope user --accept-package-agreements --accept-source-agreements --silent
                } catch {
                    Write-Warning "Failed to install ${package} via WinGet`: ${_}"
                }
            } else {
                Write-Info "[DRY RUN] Would install: $package"
            }
        }
    }

    # Install Rust if not present (rustup doesn't require admin)
    $env:CARGO_HOME = "$env:USERPROFILE\.cargo"
    $env:RUSTUP_HOME = "$env:USERPROFILE\.rustup"

    if (-not (Test-CommandExists rustup)) {
        Write-Info "Installing Rust via rustup (to user profile)..."
        if (-not $DryRun) {
            try {
                Invoke-WebRequest -Uri https://win.rustup.rs/x86_64 -OutFile "$env:TEMP\rustup-init.exe"
                & "$env:TEMP\rustup-init.exe" -y --default-toolchain stable
                Remove-Item "$env:TEMP\rustup-init.exe"

                # Add cargo to PATH for this session
                $env:Path = "$env:USERPROFILE\.cargo\bin;$env:Path"

                Write-Success "Rust installed to $env:CARGO_HOME"
            } catch {
                Write-Warning "Failed to install Rust`: ${_}"
            }
        }
    } else {
        Write-Info "Rust already installed, updating..."
        if (-not $DryRun) {
            try {
                rustup update stable
            } catch {
                Write-Warning "Failed to update Rust`: ${_}"
            }
        }
    }

    # Install cargo tools
    if (Test-CommandExists cargo) {
        $cargoTools = @(
            @{name="zoxide"; bin="zoxide"},
            @{name="eza"; bin="eza"},
            @{name="bat"; bin="bat"},
            @{name="ripgrep"; bin="rg"},
            @{name="fd-find"; bin="fd"},
            @{name="sd"; bin="sd"},
            @{name="git-delta"; bin="delta"},
            @{name="atuin"; bin="atuin"}
        )

        foreach ($tool in $cargoTools) {
            if (-not (Test-CommandExists $tool.bin)) {
                Write-Info "Installing $($tool.name) via cargo..."
                if (-not $DryRun) {
                    try {
                        cargo install $tool.name
                    } catch {
                        Write-Warning "Failed to install $($tool.name)`: ${_}"
                    }
                }
            } else {
                Write-Info "$($tool.name) already installed"
            }
        }
    }

    # Install tree-sitter CLI via npm if available
    if (Test-CommandExists npm) {
        if (-not (Test-CommandExists tree-sitter)) {
            Write-Info "Installing tree-sitter CLI via npm (global, user-scoped)..."
            if (-not $DryRun) {
                try {
                    npm install -g tree-sitter-cli
                } catch {
                    Write-Warning "Failed to install tree-sitter CLI`: ${_}"
                }
            }
        }
    } else {
        Write-Warning "npm not found, skipping tree-sitter CLI installation"
    }
}

function Copy-ConfigFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    # Create parent directory if needed
    $parent = Split-Path $Destination -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    # Copy file or directory
    $isDirectory = Test-Path -Path $Source -PathType Container

    if ($isDirectory) {
        Write-Info "Copying directory: $Source -> $Destination"
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    } else {
        Write-Info "Copying file: $Source -> $Destination"
        Copy-Item -Path $Source -Destination $Destination -Force
    }
}

function Install-Configs {
    Write-Info "Installing configuration files (copying, not symlinking)..."

    if ($DryRun) {
        Write-Info "DRY RUN - Would copy configuration files"
        return
    }

    Write-Warning "Files are being COPIED (not symlinked)"
    Write-Info "To update configs later, run: .\install_no_admin.ps1 -UpdateConfigs"

    # Define config mappings
    $configs = @{
        # Git
        "$DotfilesDir\common\git\.gitconfig" = "$env:USERPROFILE\.gitconfig"

        # WezTerm
        "$DotfilesDir\terminal\wezterm\.wezterm.lua" = "$env:USERPROFILE\.wezterm.lua"

        # Starship
        "$DotfilesDir\shell\starship\.config\starship.toml" = "$env:USERPROFILE\.config\starship.toml"

        # Neovim
        "$DotfilesDir\editor\nvim\.config\nvim" = "$env:LOCALAPPDATA\nvim"

        # LazyGit
        "$DotfilesDir\tools\lazygit\.config\lazygit" = "$env:APPDATA\lazygit"

        # Atuin
        "$DotfilesDir\tools\atuin\.config\atuin" = "$env:USERPROFILE\.config\atuin"

        # Bat
        "$DotfilesDir\tools\bat\.config\bat" = "$env:USERPROFILE\.config\bat"

        # Direnv
        "$DotfilesDir\tools\direnv\.config\direnv" = "$env:USERPROFILE\.config\direnv"

        # Eza
        "$DotfilesDir\tools\eza\.ezarc" = "$env:USERPROFILE\.ezarc"

        # PowerShell profile
        "$DotfilesDir\shell\powershell\Microsoft.PowerShell_profile.ps1" = $PROFILE
    }

    foreach ($source in $configs.Keys) {
        $destination = $configs[$source]
        if (Test-Path $source) {
            Copy-ConfigFile -Source $source -Destination $destination
        } else {
            Write-Warning "Source not found: $source"
        }
    }

    Write-Success "Configuration files copied successfully"
}

function Setup-WSL {
    if (-not (Test-WSL)) {
        Write-Info "WSL is not installed or not available"
        return
    }

    Write-Info "WSL integration detected..."
    Write-Warning "WSL setup requires running the install.sh script inside WSL"
    Write-Info "To setup WSL dotfiles, run inside WSL:"
    Write-Info "  cd ~/dotfiles && ./install.sh"
}

function Setup-PowerShell {
    Write-Info "Setting up PowerShell (user-scoped modules)..."

    # Install PowerShell modules (CurrentUser scope doesn't require admin)
    $modules = @("posh-git", "Terminal-Icons", "PSReadLine", "z")

    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Info "Installing PowerShell module: $module (CurrentUser)"
            if (-not $DryRun) {
                try {
                    Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
                    Write-Success "Installed $module"
                } catch {
                    Write-Warning "Failed to install ${module}`: ${_}"
                }
            }
        } else {
            Write-Info "$module already installed"
        }
    }

    # Create PowerShell profile if it doesn't exist
    if (-not (Test-Path $PROFILE)) {
        Write-Info "Creating PowerShell profile..."
        if (-not $DryRun) {
            $profileDir = Split-Path $PROFILE -Parent
            if (-not (Test-Path $profileDir)) {
                New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
            }
            New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        }
    }

    Write-Success "PowerShell setup complete"
}

function Setup-Neovim {
    Write-Info "Setting up Neovim with LazyVim..."

    # Check if Neovim is installed
    if (-not (Test-CommandExists nvim)) {
        Write-Info "Neovim not found, installing via Scoop..."
        if (-not $DryRun) {
            if (Test-CommandExists scoop) {
                try {
                    scoop install neovim
                    Write-Success "Neovim installed"
                } catch {
                    Write-Warning "Failed to install Neovim via Scoop`: ${_}"
                    return
                }
            } else {
                Write-Warning "Cannot install Neovim - Scoop not available"
                return
            }
        }
    }

    Write-Info "Neovim configuration will be copied from dotfiles"
    Write-Info "LazyVim will bootstrap on first nvim launch"
}

function Update-EnvironmentPath {
    Write-Info "Updating PATH environment variable..."

    $pathsToAdd = @(
        "$env:USERPROFILE\.cargo\bin",
        "$env:USERPROFILE\scoop\shims",
        "$env:APPDATA\npm"
    )

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $modified = $false

    foreach ($pathToAdd in $pathsToAdd) {
        if ((Test-Path $pathToAdd) -and ($userPath -notlike "*$pathToAdd*")) {
            Write-Info "Adding to PATH: $pathToAdd"
            if (-not $DryRun) {
                $userPath = "$pathToAdd;$userPath"
                $modified = $true
            }
        }
    }

    if ($modified -and -not $DryRun) {
        [Environment]::SetEnvironmentVariable("Path", $userPath, "User")
        $env:Path = "$userPath;$env:Path"
        Write-Success "PATH updated (restart terminal to apply changes)"
    }
}

# Main execution
function Main {
    Write-Info "========================================="
    Write-Info "   NO-ADMIN Dotfiles Installation"
    Write-Info "========================================="
    Write-Info ""
    Write-Info "This installation works WITHOUT administrator privileges"
    Write-Info "All packages and configs are user-scoped"
    Write-Info ""

    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
        Write-Info ""
    }

    $IsWSL = Test-WSL

    # Handle -UpdateConfigs flag
    if ($UpdateConfigs) {
        Write-Info "Updating configuration files from dotfiles..."
        Install-Configs
        Write-Success "Configuration files updated!"
        Write-Info "Restart your terminal or run: . `$PROFILE"
        return
    }

    # Default to all components if none specified
    if (-not $Only) {
        $Only = @("all")
    }

    # Execute based on components
    if ("all" -in $Only) {
        Backup-ExistingConfigs
        Install-Scoop
        Install-Winget
        Install-Packages
        Install-Configs
        Setup-PowerShell
        Setup-Neovim
        Update-EnvironmentPath

        if ($IsWSL) {
            Setup-WSL
        }
    } else {
        foreach ($component in $Only) {
            switch ($component) {
                "packages" {
                    Install-Scoop
                    Install-Winget
                    Install-Packages
                }
                "configs" {
                    Install-Configs
                }
                "shell" {
                    Setup-PowerShell
                }
                "neovim" {
                    Setup-Neovim
                }
                default {
                    Write-Warning "Unknown component: $component"
                    Write-Info "Available components: packages, configs, shell, neovim, all"
                }
            }
        }
        Update-EnvironmentPath
    }

    Write-Success ""
    Write-Success "========================================="
    Write-Success "   Installation Completed!"
    Write-Success "========================================="
    Write-Info ""
    Write-Info "Next steps:"
    Write-Info "  1. Restart your terminal (or run: . `$PROFILE)"
    Write-Info "  2. Configure Git user:"
    Write-Info "     git config --global user.name `"Your Name`""
    Write-Info "     git config --global user.email `"you@example.com`""
    Write-Info "  3. Launch Neovim to complete LazyVim setup: nvim"
    Write-Info ""
    Write-Info "To update configs later:"
    Write-Info "  .\install_no_admin.ps1 -UpdateConfigs"
    Write-Info ""
    Write-Info "Note: Config files are COPIED, not symlinked"
    Write-Info "      Update them periodically to sync changes"
    Write-Info ""
}

# Run main function
Main
