# PowerShell installation script for Windows
param(
    [switch]$DryRun,
    [string[]]$Only,
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
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Show help
if ($Help) {
    @"
Usage: .\install.ps1 [OPTIONS]

Options:
    -DryRun         Preview changes without applying them
    -Only <list>    Install only specified components (comma-separated)
    -Help           Show this help message

Components:
    packages, links, shell, neovim, wsl, all

Example:
    .\install.ps1 -Only packages,shell
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
        Write-Info "Installing Scoop..."
        if (-not $DryRun) {
            Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

            # Add Scoop extras bucket
            scoop bucket add extras
            scoop bucket add nerd-fonts
        }
    } else {
        Write-Info "Scoop already installed"
    }
}

function Install-Chocolatey {
    if (-not (Test-CommandExists choco)) {
        Write-Info "Installing Chocolatey..."
        if (-not $IsAdmin) {
            Write-Warning "Admin privileges required for Chocolatey installation"
            return
        }
        if (-not $DryRun) {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
    } else {
        Write-Info "Chocolatey already installed"
    }
}

function Install-Winget {
    if (-not (Test-CommandExists winget)) {
        Write-Info "Installing WinGet..."
        if (-not $DryRun) {
            # Install from Microsoft Store or GitHub
            Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
            Write-Info "Please complete WinGet installation from Microsoft Store and re-run script"
            exit 0
        }
    } else {
        Write-Info "WinGet already installed"
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
                $backupDir = Split-Path $backupPath -Parent
                New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
                Copy-Item -Path $config -Destination $backupPath -Recurse -Force
                Remove-Item -Path $config -Recurse -Force
                Write-Info "Backed up $config"
            }
        }
    }
}

function Install-Packages {
    Write-Info "Installing packages..."

    # Scoop packages
    $scoopPackagesFile = Join-Path $DotfilesDir "packages\scoop.txt"
    if ((Test-Path $scoopPackagesFile) -and (Test-CommandExists scoop)) {
        Write-Info "Installing Scoop packages..."
        $packages = Get-Content $scoopPackagesFile | Where-Object { $_ -and $_ -notmatch "^\s*#" }
        foreach ($package in $packages) {
            Write-Info "Installing $package..."
            if (-not $DryRun) {
                scoop install $package
            }
        }
    }

    # Winget packages
    $wingetPackagesFile = Join-Path $DotfilesDir "packages\winget.txt"
    if ((Test-Path $wingetPackagesFile) -and (Test-CommandExists winget)) {
        Write-Info "Installing WinGet packages..."
        $packages = Get-Content $wingetPackagesFile | Where-Object { $_ -and $_ -notmatch "^\s*#" }
        foreach ($package in $packages) {
            Write-Info "Installing $package..."
            if (-not $DryRun) {
                winget install --id $package --accept-package-agreements --accept-source-agreements
            }
        }
    }

    # Install Rust if not present
    # Ensure cargo environment variables point to correct locations
    $env:CARGO_HOME = "$env:USERPROFILE\.cargo"
    $env:RUSTUP_HOME = "$env:USERPROFILE\.rustup"

    if (-not (Test-CommandExists rustup)) {
        Write-Info "Installing Rust via rustup..."
        if (-not $DryRun) {
            Invoke-WebRequest -Uri https://win.rustup.rs/x86_64 -OutFile rustup-init.exe
            .\rustup-init.exe -y
            Remove-Item rustup-init.exe
            $env:Path += ";$env:USERPROFILE\.cargo\bin"
        }
    } else {
        Write-Info "Updating Rust to latest stable..."
        if (-not $DryRun) {
            try {
                rustup update stable
            } catch {
                Write-Warning "Rustup update failed, reinstalling..."
                Remove-Item -Path "$env:USERPROFILE\.cargo" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$env:USERPROFILE\.rustup" -Recurse -Force -ErrorAction SilentlyContinue
                Invoke-WebRequest -Uri https://win.rustup.rs/x86_64 -OutFile rustup-init.exe
                .\rustup-init.exe -y
                Remove-Item rustup-init.exe
                $env:Path += ";$env:USERPROFILE\.cargo\bin"
            }
        }
    }

    # Install cargo tools
    $cargoTools = @("zoxide", "eza", "bat", "ripgrep", "fd-find", "sd", "git-delta", "atuin")
    foreach ($tool in $cargoTools) {
        if (-not (Test-CommandExists $tool)) {
            Write-Info "Installing $tool..."
            if (-not $DryRun) {
                cargo install $tool
            }
        }
    }

    # Install tree-sitter CLI via npm if not available
    if (-not (Test-CommandExists tree-sitter)) {
        if (Test-CommandExists npm) {
            Write-Info "Installing tree-sitter CLI via npm..."
            if (-not $DryRun) {
                npm install -g tree-sitter-cli
            }
        } else {
            Write-Warning "npm not found, skipping tree-sitter CLI installation"
        }
    }
}

function New-SymbolicLink {
    param(
        [string]$Path,
        [string]$Target
    )

    # Remove existing file/link if exists
    if (Test-Path $Path) {
        Remove-Item $Path -Force -Recurse
    }

    # Create parent directory if needed
    $parent = Split-Path $Path -Parent
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    # Create symbolic link
    $isDirectory = Test-Path -Path $Target -PathType Container
    if ($isDirectory) {
        cmd /c mklink /D "`"$Path`"" "`"$Target`"" 2>$null
    } else {
        cmd /c mklink "`"$Path`"" "`"$Target`"" 2>$null
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to create symbolic link from $Path to $Target"
        Write-Info "Copying instead..."
        if ($isDirectory) {
            Copy-Item -Path $Target -Destination $Path -Recurse -Force
        } else {
            Copy-Item -Path $Target -Destination $Path -Force
        }
    }
}

function Install-Configs {
    Write-Info "Installing configuration files..."

    if ($DryRun) {
        Write-Info "DRY RUN - Would create symbolic links"
        return
    }

    # Check for admin privileges for symlinks
    if (-not $IsAdmin) {
        Write-Warning "Running without admin privileges - will copy files instead of creating symlinks"
    }

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

        # Mise/rtx
        "$DotfilesDir\common\mise\.config\mise" = "$env:USERPROFILE\.config\mise"
    }

    foreach ($source in $configs.Keys) {
        $target = $configs[$source]
        if (Test-Path $source) {
            Write-Info "Linking $source -> $target"
            New-SymbolicLink -Path $target -Target $source
        }
    }
}

function Setup-WSL {
    if (-not (Test-WSL)) {
        Write-Info "WSL is not installed or not available"
        return
    }

    Write-Info "Setting up WSL integration..."

    if (-not $DryRun) {
        # Copy install script to WSL
        wsl cp /mnt/c/Projects/dotfiles/install.sh ~/install.sh
        wsl chmod +x ~/install.sh

        # Run installation in WSL
        Write-Info "Running installation script in WSL..."
        wsl ~/install.sh
    }
}

function Setup-PowerShell {
    Write-Info "Setting up PowerShell..."

    # Install PowerShell modules
    $modules = @("posh-git", "Terminal-Icons", "PSReadLine", "z")

    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Info "Installing PowerShell module: $module"
            if (-not $DryRun) {
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
            }
        }
    }

    # Create PowerShell profile if it doesn't exist
    if (-not (Test-Path $PROFILE)) {
        Write-Info "Creating PowerShell profile..."
        if (-not $DryRun) {
            New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        }
    }

    # Add initialization to profile
    $profileContent = @"
# Dotfiles PowerShell Configuration

# Import modules
Import-Module posh-git
Import-Module Terminal-Icons
Import-Module PSReadLine
Import-Module z

# PSReadLine configuration
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name lg -Value lazygit
Set-Alias -Name v -Value nvim
Set-Alias -Name ll -Value 'eza -la'
Set-Alias -Name cat -Value bat

# Starship prompt
if (Test-CommandExists starship) {
    Invoke-Expression (&starship init powershell)
}

# Zoxide
if (Test-CommandExists zoxide) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Atuin
if (Test-CommandExists atuin) {
    Invoke-Expression (& { (atuin init powershell | Out-String) })
}
"@

    if (-not $DryRun) {
        # Check if our config is already in the profile
        $currentProfile = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
        if ($currentProfile -notmatch "Dotfiles PowerShell Configuration") {
            Add-Content -Path $PROFILE -Value $profileContent
        }
    }
}

function Setup-Neovim {
    Write-Info "Setting up Neovim with LazyVim..."

    # Install Neovim if not present
    if (-not (Test-CommandExists nvim)) {
        Write-Info "Installing Neovim..."
        if (-not $DryRun) {
            if (Test-CommandExists scoop) {
                scoop install neovim
            } elseif (Test-CommandExists winget) {
                winget install Neovim.Neovim
            } else {
                Write-Warning "Cannot install Neovim - no package manager available"
                return
            }
        }
    }

    # Install LazyVim
    $nvimConfigPath = "$env:LOCALAPPDATA\nvim"
    if (-not (Test-Path $nvimConfigPath)) {
        Write-Info "Installing LazyVim..."
        if (-not $DryRun) {
            git clone https://github.com/LazyVim/starter $nvimConfigPath
            Remove-Item -Path "$nvimConfigPath\.git" -Recurse -Force
        }
    }
}

# Main execution
function Main {
    Write-Info "Starting dotfiles installation for Windows..."

    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
    }

    $IsWSL = Test-WSL

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
                "links" {
                    Install-Configs
                }
                "shell" {
                    Setup-PowerShell
                }
                "neovim" {
                    Setup-Neovim
                }
                "wsl" {
                    Setup-WSL
                }
                default {
                    Write-Warning "Unknown component: $component"
                }
            }
        }
    }

    Write-Success "Dotfiles installation completed!"
    Write-Info "Please restart your terminal or run: . `$PROFILE"
}

# Run main function
Main