@echo off
REM Auto-download DLLs wrapper for PowerShell script

echo ========================================
echo  Inno Setup DLL Auto-Downloader
echo ========================================
echo.

REM Check PowerShell availability
where powershell >nul 2>nul
if errorlevel 1 (
    echo ERROR: PowerShell not found
    echo Please install PowerShell or download DLLs manually
    pause
    exit /b 1
)

echo Starting PowerShell download script...
echo.

REM Run PowerShell script with execution policy bypass
powershell -ExecutionPolicy Bypass -File "%~dp0download-dlls.ps1" %*

if errorlevel 1 (
    echo.
    echo Download script encountered errors.
    echo See messages above for details.
    pause
    exit /b 1
)

echo.
echo Done!
pause
