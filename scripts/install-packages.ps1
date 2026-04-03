# PowerShell Package Installation Script
# Installs packages on Windows using Scoop, WinGet, and Chocolatey

param(
    [string]$PackagesDir = "$PSScriptRoot\..\packages",
    [switch]$SkipScoop,
    [switch]$SkipWinget,
    [switch]$SkipChocolatey,
    [switch]$SkipLanguageTools
)

# Colors for output
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Info { Write-ColorOutput "[INFO] $args" "Cyan" }
function Write-Success { Write-ColorOutput "[SUCCESS] $args" "Green" }
function Write-Warning { Write-ColorOutput "[WARNING] $args" "Yellow" }
function Write-Error { Write-ColorOutput "[ERROR] $args" "Red"; exit 1 }

# Check if running as administrator
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $user
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Install Scoop
function Install-ScoopPackageManager {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Info "Installing Scoop..."
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

        # Add essential buckets
        scoop bucket add extras
        scoop bucket add nerd-fonts
        scoop bucket add java
        scoop bucket add versions
    } else {
        Write-Info "Scoop is already installed"
    }
}

# Install packages with Scoop
function Install-ScoopPackages {
    param([string]$PackageFile)

    if (-not (Test-Path $PackageFile)) {
        Write-Warning "Package file not found: $PackageFile"
        return
    }

    Write-Info "Installing packages with Scoop..."

    Get-Content $PackageFile | ForEach-Object {
        $package = $_.Trim()

        # Skip comments and empty lines
        if ($package -match "^#" -or [string]::IsNullOrWhiteSpace($package)) {
            return
        }

        Write-Info "Installing: $package"
        try {
            scoop install $package
        } catch {
            Write-Warning "Failed to install: $package"
        }
    }
}

# Install WinGet
function Install-WinGetPackageManager {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Info "Installing WinGet..."

        # Check if Windows version supports WinGet
        $version = [Environment]::OSVersion.Version
        if ($version.Major -lt 10 -or ($version.Major -eq 10 -and $version.Build -lt 17763)) {
            Write-Warning "WinGet requires Windows 10 version 1809 or later"
            return
        }

        # Install from Microsoft Store
        Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
        Write-Info "Please complete WinGet installation from Microsoft Store and re-run script"
        exit 0
    } else {
        Write-Info "WinGet is already installed"
    }
}

# Install packages with WinGet
function Install-WinGetPackages {
    param([string]$PackageFile)

    if (-not (Test-Path $PackageFile)) {
        Write-Warning "Package file not found: $PackageFile"
        return
    }

    Write-Info "Installing packages with WinGet..."

    Get-Content $PackageFile | ForEach-Object {
        $package = $_.Trim()

        # Skip comments and empty lines
        if ($package -match "^#" -or [string]::IsNullOrWhiteSpace($package)) {
            return
        }

        Write-Info "Installing: $package"
        try {
            winget install --id $package --accept-package-agreements --accept-source-agreements
        } catch {
            Write-Warning "Failed to install: $package"
        }
    }
}

# Install Chocolatey
function Install-ChocolateyPackageManager {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        if (-not (Test-Administrator)) {
            Write-Warning "Chocolatey installation requires administrator privileges"
            return
        }

        Write-Info "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Info "Chocolatey is already installed"
    }
}

# Install packages with Chocolatey
function Install-ChocolateyPackages {
    param([string]$PackageFile)

    if (-not (Test-Path $PackageFile)) {
        Write-Warning "Package file not found: $PackageFile"
        return
    }

    if (-not (Test-Administrator)) {
        Write-Warning "Chocolatey package installation requires administrator privileges"
        return
    }

    Write-Info "Installing packages with Chocolatey..."

    Get-Content $PackageFile | ForEach-Object {
        $package = $_.Trim()

        # Skip comments and empty lines
        if ($package -match "^#" -or [string]::IsNullOrWhiteSpace($package)) {
            return
        }

        Write-Info "Installing: $package"
        try {
            choco install $package -y
        } catch {
            Write-Warning "Failed to install: $package"
        }
    }
}

# Install Rust
function Install-Rust {
    if (-not (Get-Command rustc -ErrorAction SilentlyContinue)) {
        Write-Info "Installing Rust..."
        Invoke-WebRequest -Uri https://win.rustup.rs/x86_64 -OutFile rustup-init.exe
        .\rustup-init.exe -y
        Remove-Item rustup-init.exe

        # Add to PATH
        $env:Path += ";$env:USERPROFILE\.cargo\bin"
        [Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::User)
    } else {
        Write-Info "Rust is already installed"
    }

    # Install Rust tools
    Write-Info "Installing Rust tools..."
    $rustTools = @(
        "zoxide",
        "eza",
        "bat",
        "ripgrep",
        "fd-find",
        "sd",
        "git-delta",
        "atuin",
        "cargo-update"
    )

    foreach ($tool in $rustTools) {
        Write-Info "Installing: $tool"
        cargo install $tool
    }
}

# Install Node.js tools
function Install-NodeTools {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Warning "Node.js is not installed"
        return
    }

    Write-Info "Installing Node.js global packages..."
    $nodePackages = @(
        "pnpm",
        "yarn",
        "npm-check-updates",
        "prettier",
        "eslint",
        "typescript",
        "tsx",
        "nodemon"
    )

    foreach ($package in $nodePackages) {
        Write-Info "Installing: $package"
        npm install -g $package
    }
}

# Install Python tools
function Install-PythonTools {
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Warning "Python is not installed"
        return
    }

    Write-Info "Installing Python tools..."
    $pythonPackages = @(
        "pip",
        "setuptools",
        "wheel",
        "pipx",
        "black",
        "ruff",
        "mypy",
        "pytest",
        "ipython",
        "jupyter"
    )

    foreach ($package in $pythonPackages) {
        Write-Info "Installing: $package"
        pip install --user --upgrade $package
    }
}

# Install PowerShell modules
function Install-PowerShellModules {
    Write-Info "Installing PowerShell modules..."

    $modules = @(
        "posh-git",
        "Terminal-Icons",
        "PSReadLine",
        "z",
        "PSFzf"
    )

    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            Write-Info "Installing module: $module"
            Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
        } else {
            Write-Info "Module already installed: $module"
        }
    }
}

# Main installation function
function Main {
    Write-Info "Starting package installation..."
    Write-Info "Packages directory: $PackagesDir"

    if (Test-Administrator) {
        Write-Info "Running with administrator privileges"
    } else {
        Write-Warning "Running without administrator privileges - some installations may fail"
    }

    # Install package managers
    if (-not $SkipScoop) {
        Install-ScoopPackageManager
        Install-ScoopPackages -PackageFile "$PackagesDir\scoop.txt"
    }

    if (-not $SkipWinget) {
        Install-WinGetPackageManager
        Install-WinGetPackages -PackageFile "$PackagesDir\winget.txt"
    }

    if (-not $SkipChocolatey) {
        Install-ChocolateyPackageManager
        Install-ChocolateyPackages -PackageFile "$PackagesDir\choco.txt"
    }

    # Install language tools
    if (-not $SkipLanguageTools) {
        Install-Rust
        Install-NodeTools
        Install-PythonTools
    }

    # Install PowerShell modules
    Install-PowerShellModules

    Write-Success "Package installation completed!"
    Write-Info "Please restart your terminal to apply changes"
}

# Run main function
Main