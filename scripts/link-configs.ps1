# PowerShell script for creating symbolic links on Windows
# Requires administrator privileges for symbolic links

param(
    [string]$DotfilesDir = "$PSScriptRoot\..",
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Unlink
)

# Check if running as administrator
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $user
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Colors for output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Info { Write-ColorOutput "[INFO] $args" "Cyan" }
function Write-Success { Write-ColorOutput "[SUCCESS] $args" "Green" }
function Write-Warning { Write-ColorOutput "[WARNING] $args" "Yellow" }
function Write-Error { Write-ColorOutput "[ERROR] $args" "Red" }

# Backup existing file/directory
function Backup-Item {
    param([string]$Path)

    if (Test-Path $Path) {
        $backupDir = "$env:USERPROFILE\.dotfiles-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
        }

        $relativePath = $Path.Replace($env:USERPROFILE, "").TrimStart("\")
        $backupPath = Join-Path $backupDir $relativePath
        $backupParent = Split-Path $backupPath -Parent

        if ($backupParent -and -not (Test-Path $backupParent)) {
            New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
        }

        Write-Info "Backing up: $Path -> $backupPath"
        if (-not $DryRun) {
            Move-Item -Path $Path -Destination $backupPath -Force
        }
    }
}

# Create symbolic link
function New-SymbolicLink {
    param(
        [string]$Path,
        [string]$Target,
        [bool]$IsDirectory = $false
    )

    # Resolve full paths
    $Target = Resolve-Path $Target -ErrorAction SilentlyContinue
    if (-not $Target) {
        Write-Warning "Target does not exist: $Target"
        return
    }

    # Check if target exists
    if (-not (Test-Path $Target)) {
        Write-Warning "Target does not exist: $Target"
        return
    }

    # Determine if target is directory
    if (Test-Path $Target -PathType Container) {
        $IsDirectory = $true
    }

    # Check if link already exists
    if (Test-Path $Path) {
        if ($Force) {
            Write-Info "Removing existing item: $Path"
            if (-not $DryRun) {
                Backup-Item -Path $Path
            }
        } else {
            Write-Warning "Path already exists: $Path"
            return
        }
    }

    # Create parent directory if needed
    $parent = Split-Path $Path -Parent
    if ($parent -and -not (Test-Path $parent)) {
        Write-Info "Creating directory: $parent"
        if (-not $DryRun) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
    }

    # Create symbolic link
    Write-Info "Creating link: $Path -> $Target"
    if (-not $DryRun) {
        if ($IsDirectory) {
            cmd /c mklink /D "`"$Path`"" "`"$Target`"" 2>&1 | Out-Null
        } else {
            cmd /c mklink "`"$Path`"" "`"$Target`"" 2>&1 | Out-Null
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to create symbolic link, copying instead"
            if ($IsDirectory) {
                Copy-Item -Path $Target -Destination $Path -Recurse -Force
            } else {
                Copy-Item -Path $Target -Destination $Path -Force
            }
        } else {
            Write-Success "Created link: $Path"
        }
    }
}

# Remove symbolic link
function Remove-SymbolicLink {
    param([string]$Path)

    if (Test-Path $Path) {
        $item = Get-Item $Path -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Info "Removing symbolic link: $Path"
            if (-not $DryRun) {
                Remove-Item $Path -Force
                Write-Success "Removed link: $Path"
            }
        } else {
            Write-Warning "Not a symbolic link: $Path"
        }
    } else {
        Write-Warning "Path does not exist: $Path"
    }
}

# Configuration mappings
$configs = @{
    # Git
    "$DotfilesDir\common\git\.gitconfig" = "$env:USERPROFILE\.gitconfig"
    "$DotfilesDir\common\git\.gitignore_global" = "$env:USERPROFILE\.gitignore_global"

    # WezTerm
    "$DotfilesDir\terminal\wezterm\.wezterm.lua" = "$env:USERPROFILE\.wezterm.lua"

    # Starship
    "$DotfilesDir\shell\starship\.config\starship.toml" = "$env:USERPROFILE\.config\starship.toml"

    # Neovim (Windows uses LocalAppData)
    "$DotfilesDir\editor\nvim\.config\nvim" = "$env:LOCALAPPDATA\nvim"

    # LazyGit (Windows uses AppData)
    "$DotfilesDir\tools\lazygit\.config\lazygit" = "$env:APPDATA\lazygit"

    # Atuin
    "$DotfilesDir\tools\atuin\.config\atuin" = "$env:USERPROFILE\.config\atuin"

    # Mise/rtx
    "$DotfilesDir\common\mise\.config\mise" = "$env:USERPROFILE\.config\mise"

    # PowerShell profile
    "$DotfilesDir\shell\powershell\Microsoft.PowerShell_profile.ps1" = $PROFILE

    # Windows Terminal settings (if exists)
    "$DotfilesDir\terminal\windows-terminal\settings.json" = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
}

# WSL-specific configurations
$wslConfigs = @{
    # Bash
    "$DotfilesDir\shell\bash\.bashrc" = "$env:USERPROFILE\.bashrc"
    "$DotfilesDir\shell\bash\.bash_profile" = "$env:USERPROFILE\.bash_profile"

    # Zsh
    "$DotfilesDir\shell\zsh\.zshrc" = "$env:USERPROFILE\.zshrc"
    "$DotfilesDir\shell\zsh\.zshenv" = "$env:USERPROFILE\.zshenv"

    # Tmux
    "$DotfilesDir\tools\tmux\.tmux.conf" = "$env:USERPROFILE\.tmux.conf"

    # Vim
    "$DotfilesDir\common\vim\.vimrc" = "$env:USERPROFILE\.vimrc"
}

# Main function
function Main {
    Write-Info "Dotfiles directory: $DotfilesDir"

    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
    }

    if (-not (Test-Administrator)) {
        Write-Warning "Not running as administrator - symbolic links will be replaced with copies"
    }

    if ($Unlink) {
        Write-Info "Removing symbolic links..."
        foreach ($target in $configs.Values) {
            Remove-SymbolicLink -Path $target
        }

        # Check if WSL is available
        if (Get-Command wsl -ErrorAction SilentlyContinue) {
            foreach ($target in $wslConfigs.Values) {
                Remove-SymbolicLink -Path $target
            }
        }
    } else {
        Write-Info "Creating symbolic links..."
        foreach ($source in $configs.Keys) {
            $target = $configs[$source]
            if (Test-Path $source) {
                New-SymbolicLink -Path $target -Target $source
            } else {
                Write-Warning "Source does not exist: $source"
            }
        }

        # Check if WSL is available
        if (Get-Command wsl -ErrorAction SilentlyContinue) {
            Write-Info "Creating WSL-specific links..."
            foreach ($source in $wslConfigs.Keys) {
                $target = $wslConfigs[$source]
                if (Test-Path $source) {
                    New-SymbolicLink -Path $target -Target $source
                }
            }
        }
    }

    Write-Success "Configuration linking completed!"
}

# Create PowerShell profile if needed
function Initialize-PowerShellProfile {
    $profilePath = "$DotfilesDir\shell\powershell\Microsoft.PowerShell_profile.ps1"

    if (-not (Test-Path $profilePath)) {
        Write-Info "Creating PowerShell profile..."

        $profileContent = @'
# PowerShell Profile

# Import modules
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}
if (Get-Module -ListAvailable -Name z) {
    Import-Module z
}

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name lg -Value lazygit
Set-Alias -Name v -Value nvim
Set-Alias -Name ll -Value 'eza -la'

# Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# Atuin
if (Get-Command atuin -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (atuin init powershell | Out-String) })
}

# Helper functions
function mkcd {
    param($Path)
    New-Item -ItemType Directory -Force -Path $Path
    Set-Location $Path
}

function which {
    param($Command)
    Get-Command $Command | Select-Object -ExpandProperty Source
}

function reload {
    . $PROFILE
}
'@

        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
        }

        $profileContent | Out-File -FilePath $profilePath -Encoding UTF8
        Write-Success "Created PowerShell profile"
    }
}

# Initialize profile if needed
Initialize-PowerShellProfile

# Run main function
Main