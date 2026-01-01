@echo off
REM Quick DLL verification test
REM Tests if Zstd DLLs are accessible

echo ========================================
echo  Zstd DLL Verification Test
echo ========================================
echo.

set FILES_DIR=%~dp0..\..\Files

echo Checking DLL files...
echo.

if exist "%FILES_DIR%\iszstd.dll" (
    echo [OK] iszstd.dll found
    for %%A in ("%FILES_DIR%\iszstd.dll") do echo     Size: %%~zA bytes
) else (
    echo [ERROR] iszstd.dll NOT FOUND
    set ERROR=1
)

echo.

if exist "%FILES_DIR%\iszstd-x64.dll" (
    echo [OK] iszstd-x64.dll found
    for %%A in ("%FILES_DIR%\iszstd-x64.dll") do echo     Size: %%~zA bytes
) else (
    echo [ERROR] iszstd-x64.dll NOT FOUND
    set ERROR=1
)

echo.
echo ========================================

if defined ERROR (
    echo [FAIL] Some DLLs are missing
    echo.
    echo Run: Components\download-dlls.bat
    exit /b 1
) else (
    echo [SUCCESS] All Zstd DLLs are ready!
    echo.
    echo Next steps:
    echo   1. Compile Inno Setup with Delphi
    echo   2. DLLs will be loaded automatically
    echo   3. Smart compression will use Zstd for binaries
    echo.
    echo Note: Brotli DLLs not found (optional)
    echo   - Text files will use LZMA2 fallback
    echo   - Binary files will use Zstd
)

echo.
pause
