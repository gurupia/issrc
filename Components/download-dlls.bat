@echo off
REM Download pre-built Brotli and Zstandard DLLs
REM Part of Inno Setup Smart Compression implementation

setlocal enabledelayedexpansion

echo ========================================
echo Downloading Compression DLLs
echo ========================================
echo.

REM Check for PowerShell
where powershell >nul 2>nul
if errorlevel 1 (
    echo ERROR: PowerShell not found
    echo Please download DLLs manually from:
    echo   Brotli: https://github.com/google/brotli/releases
    echo   Zstandard: https://github.com/facebook/zstd/releases
    pause
    exit /b 1
)

REM Create Files directory if not exists
if not exist "..\..\Files" mkdir "..\..\Files"

echo [1/4] Downloading Brotli DLLs...
echo.
echo NOTE: Pre-built Brotli DLLs are not available in official releases.
echo You need to either:
echo   1. Build from source using build-brotli.bat
echo   2. Download from third-party sources
echo   3. Use DLLs from existing Brotli installation
echo.

echo [2/4] Downloading Zstandard DLLs...
echo.
echo Downloading from: https://github.com/facebook/zstd/releases/latest
echo.

REM Download Zstandard (example - adjust version as needed)
powershell -Command "& { ^
    $ProgressPreference = 'SilentlyContinue'; ^
    Write-Host 'Checking latest Zstandard release...'; ^
    try { ^
        $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/facebook/zstd/releases/latest'; ^
        $version = $release.tag_name; ^
        Write-Host \"Latest version: $version\"; ^
        Write-Host 'Note: DLL downloads require manual extraction from release assets'; ^
    } catch { ^
        Write-Host 'Could not fetch release info. Please download manually.'; ^
    } ^
}"

echo.
echo ========================================
echo Manual Download Required
echo ========================================
echo.
echo Please download DLLs manually:
echo.
echo 1. Brotli (6 files):
echo    URL: https://github.com/google/brotli/releases
echo    Files needed:
echo      - brotlicommon.dll (32-bit) -^> isbrotlicommon.dll
echo      - brotlienc.dll (32-bit) -^> isbrotlienc.dll
echo      - brotlidec.dll (32-bit) -^> isbrotlidec.dll
echo      - brotlicommon.dll (64-bit) -^> isbrotlicommon-x64.dll
echo      - brotlienc.dll (64-bit) -^> isbrotlienc-x64.dll
echo      - brotlidec.dll (64-bit) -^> isbrotlidec-x64.dll
echo.
echo 2. Zstandard (2 files):
echo    URL: https://github.com/facebook/zstd/releases
echo    Files needed:
echo      - zstd.dll (32-bit) -^> iszstd.dll
echo      - zstd.dll (64-bit) -^> iszstd-x64.dll
echo.
echo Copy all files to: %CD%\..\..\Files\
echo.
echo [3/4] Alternative: Build from source
echo    Run: build-compression-libs.bat
echo.
echo [4/4] Alternative: Skip DLLs for now
echo    Continue with Phase 4 implementation
echo    DLLs can be added later for testing
echo.

pause
endlocal
