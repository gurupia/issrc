@echo off
REM Master build script for Smart Compression
setlocal enabledelayedexpansion

echo ========================================
echo Smart Compression Build System
echo Inno Setup 7.1 - Phase 1+2
echo ========================================
echo.

REM Check prerequisites
where cmake >nul 2>nul
if errorlevel 1 (
    echo ERROR: CMake not found
    echo Install Visual Studio 2022 with CMake support
    pause
    exit /b 1
)

where git >nul 2>nul
if errorlevel 1 (
    echo ERROR: Git not found
    echo Install Git for Windows from https://git-scm.com/
    pause
    exit /b 1
)

echo [OK] Prerequisites check passed
echo.

REM Build Brotli
echo ========================================
echo Phase 1: Building Brotli
echo ========================================
call build-brotli.bat
if errorlevel 1 (
    echo ERROR: Brotli build failed
    pause
    exit /b 1
)

echo.
timeout /t 2 /nobreak >nul

REM Build Zstandard
echo ========================================
echo Phase 2: Building Zstandard
echo ========================================
call build-zstd.bat
if errorlevel 1 (
    echo ERROR: Zstandard build failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD COMPLETE!
echo ========================================
echo.
echo Libraries built successfully:
dir /B ..\..\Files\isbrotli*.dll 2>nul
dir /B ..\..\Files\iszstd*.dll 2>nul
echo.
echo Next steps:
echo 1. Implement Pascal bindings (Compression.Brotli.pas)
echo 2. Implement Pascal bindings (Compression.Zstd.pas)
echo 3. Write unit tests
echo.
echo See SMART_COMPRESSION_ROADMAP.md for details
echo.
pause

endlocal
