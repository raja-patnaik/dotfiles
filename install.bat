@echo off
:: Windows batch wrapper for PowerShell installation script
:: This makes it easier to run the installer without PowerShell execution policy issues

echo ========================================
echo   Dotfiles Installation for Windows
echo ========================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges
) else (
    echo Running without administrator privileges
    echo Note: Symbolic links will not be created, files will be copied instead
    echo For best results, run as administrator
    echo.
)

:: Run PowerShell script with bypass execution policy
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*

if %errorLevel% == 0 (
    echo.
    echo Installation completed successfully!
    echo Please restart your terminal to apply changes.
) else (
    echo.
    echo Installation failed with error code %errorLevel%
)

pause