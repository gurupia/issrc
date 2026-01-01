@echo off
REM Simplified Zstandard build script for Inno Setup
setlocal enabledelayedexpansion

echo ========================================
echo Building Zstandard Library
echo ========================================
echo.

REM Clone if needed
if not exist "Zstandard" (
    echo [1/5] Cloning Zstandard...
    git clone --depth 1 https://github.com/facebook/zstd.git Zstandard
    if errorlevel 1 (
        echo ERROR: Git clone failed
        exit /b 1
    )
)

cd Zstandard\build\cmake

REM Build 32-bit
echo.
echo [2/5] Configuring Zstandard 32-bit...
cmake -G "Visual Studio 17 2022" -A Win32 -DCMAKE_BUILD_TYPE=Release -DZSTD_BUILD_SHARED=ON -DZSTD_BUILD_STATIC=OFF -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_TESTS=OFF -S . -B build-win32
if errorlevel 1 (
    echo ERROR: CMake config failed (32-bit)
    cd ..\..\..
    exit /b 1
)

echo [3/5] Building Zstandard 32-bit...
cmake --build build-win32 --config Release
if errorlevel 1 (
    echo ERROR: Build failed (32-bit)
    cd ..\..\..
    exit /b 1
)

REM Build 64-bit
echo.
echo [4/5] Configuring Zstandard 64-bit...
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release -DZSTD_BUILD_SHARED=ON -DZSTD_BUILD_STATIC=OFF -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_TESTS=OFF -S . -B build-x64
if errorlevel 1 (
    echo ERROR: CMake config failed (64-bit)
    cd ..\..\..
    exit /b 1
)

echo [5/5] Building Zstandard 64-bit...
cmake --build build-x64 --config Release
if errorlevel 1 (
    echo ERROR: Build failed (64-bit)
    cd ..\..\..
    exit /b 1
)

REM Copy DLLs
echo.
echo Copying DLLs to Files directory...
if not exist "..\..\..\Files" mkdir "..\..\..\Files"

copy /Y build-win32\lib\Release\zstd.dll ..\..\..\Files\iszstd.dll
copy /Y build-x64\lib\Release\zstd.dll ..\..\..\Files\iszstd-x64.dll

cd ..\..\..

echo.
echo ========================================
echo Zstandard build complete!
echo ========================================
echo.

endlocal
