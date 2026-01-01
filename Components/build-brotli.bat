@echo off
REM Simplified Brotli build script for Inno Setup
setlocal enabledelayedexpansion

echo ========================================
echo Building Brotli Library
echo ========================================
echo.

REM Clone if needed
if not exist "Brotli" (
    echo [1/5] Cloning Brotli...
    git clone --depth 1 https://github.com/google/brotli.git Brotli
    if errorlevel 1 (
        echo ERROR: Git clone failed
        exit /b 1
    )
)

cd Brotli

REM Build 32-bit
echo.
echo [2/5] Configuring Brotli 32-bit...
cmake -G "Visual Studio 17 2022" -A Win32 -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBROTLI_DISABLE_TESTS=ON -S . -B build-win32
if errorlevel 1 (
    echo ERROR: CMake config failed (32-bit)
    cd ..
    exit /b 1
)

echo [3/5] Building Brotli 32-bit...
cmake --build build-win32 --config Release
if errorlevel 1 (
    echo ERROR: Build failed (32-bit)
    cd ..
    exit /b 1
)

REM Build 64-bit
echo.
echo [4/5] Configuring Brotli 64-bit...
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBROTLI_DISABLE_TESTS=ON -S . -B build-x64
if errorlevel 1 (
    echo ERROR: CMake config failed (64-bit)
    cd ..
    exit /b 1
)

echo [5/5] Building Brotli 64-bit...
cmake --build build-x64 --config Release
if errorlevel 1 (
    echo ERROR: Build failed (64-bit)
    cd ..
    exit /b 1
)

REM Copy DLLs
echo.
echo Copying DLLs to Files directory...
if not exist "..\..\Files" mkdir "..\..\Files"

copy /Y build-win32\Release\brotlicommon.dll ..\..\Files\isbrotlicommon.dll
copy /Y build-win32\Release\brotlienc.dll ..\..\Files\isbrotlienc.dll
copy /Y build-win32\Release\brotlidec.dll ..\..\Files\isbrotlidec.dll

copy /Y build-x64\Release\brotlicommon.dll ..\..\Files\isbrotlicommon-x64.dll
copy /Y build-x64\Release\brotlienc.dll ..\..\Files\isbrotlienc-x64.dll
copy /Y build-x64\Release\brotlidec.dll ..\..\Files\isbrotlidec-x64.dll

cd ..

echo.
echo ========================================
echo Brotli build complete!
echo ========================================
echo.

endlocal
