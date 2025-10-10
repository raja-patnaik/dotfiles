@echo off
:: Windows batch wrapper for NO-ADMIN PowerShell installation script
:: This script installs dotfiles WITHOUT requiring administrator privileges

echo =========================================================
echo   Dotfiles Installation for Windows (NO ADMIN REQUIRED)
echo =========================================================
echo.
echo This installation script works WITHOUT administrator rights
echo All packages and configurations are user-scoped
echo.

:: Check if running as administrator (inform user, but continue anyway)
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Running with administrator privileges
    echo [INFO] This script is designed for NO-ADMIN installation
    echo [INFO] Consider using install.bat instead for better symlink support
    echo.
    timeout /t 3 >nul
) else (
    echo [INFO] Running without administrator privileges (as expected)
    echo [INFO] All installations will be user-scoped
    echo.
)

:: Run PowerShell script with bypass execution policy
echo Starting installation...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_no_admin.ps1" %*

:: Check exit code
if %errorLevel% == 0 (
    echo.
    echo =========================================================
    echo   Installation completed successfully!
    echo =========================================================
    echo.
    echo IMPORTANT: Please restart your terminal to apply changes
    echo.
    echo To update configurations later, run:
    echo   install_no_admin.bat -UpdateConfigs
    echo.
) else (
    echo.
    echo =========================================================
    echo   Installation failed with error code %errorLevel%
    echo =========================================================
    echo.
    echo Please check the error messages above and try again
    echo.
    echo For help, run: install_no_admin.bat -Help
    echo.
)

pause
