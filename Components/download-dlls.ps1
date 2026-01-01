# Auto-download compression DLLs for Inno Setup Smart Compression
# PowerShell script to download pre-built Brotli and Zstandard DLLs

param(
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$FilesDir = Join-Path $PSScriptRoot "..\..\Files"
$TempDir = Join-Path $env:TEMP "InnoSetup_DLLs"

# DLL URLs (update these with actual release URLs)
$BrotliVersion = "1.1.0"
$ZstdVersion = "1.5.5"

$BrotliUrl = "https://github.com/google/brotli/releases/download/v$BrotliVersion/brotli-v$BrotliVersion-win-x64.zip"
$ZstdUrl32 = "https://github.com/facebook/zstd/releases/download/v$ZstdVersion/zstd-v$ZstdVersion-win32.zip"
$ZstdUrl64 = "https://github.com/facebook/zstd/releases/download/v$ZstdVersion/zstd-v$ZstdVersion-win64.zip"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Inno Setup DLL Auto-Downloader" -ForegroundColor Cyan
Write-Host "  Smart Compression System" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create directories
if (-not (Test-Path $FilesDir)) {
    New-Item -ItemType Directory -Path $FilesDir -Force | Out-Null
    Write-Host "[OK] Created Files directory" -ForegroundColor Green
}

if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
}

# Function to download and extract
function Download-And-Extract {
    param(
        [string]$Url,
        [string]$Name,
        [string]$OutputDir
    )
    
    Write-Host ""
    Write-Host "Downloading $Name..." -ForegroundColor Yellow
    
    $zipFile = Join-Path $TempDir "$Name.zip"
    $extractDir = Join-Path $TempDir $Name
    
    try {
        # Download
        Invoke-WebRequest -Uri $Url -OutFile $zipFile -UseBasicParsing
        Write-Host "  [OK] Downloaded" -ForegroundColor Green
        
        # Extract
        Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
        Write-Host "  [OK] Extracted" -ForegroundColor Green
        
        return $extractDir
    }
    catch {
        Write-Host "  [ERROR] Failed: $_" -ForegroundColor Red
        return $null
    }
}

# Function to find and copy DLL
function Find-And-Copy-DLL {
    param(
        [string]$SourceDir,
        [string]$DllPattern,
        [string]$TargetName
    )
    
    $targetPath = Join-Path $FilesDir $TargetName
    
    # Check if already exists
    if ((Test-Path $targetPath) -and -not $Force) {
        Write-Host "  [SKIP] $TargetName already exists" -ForegroundColor Gray
        return $true
    }
    
    # Find DLL
    $dll = Get-ChildItem -Path $SourceDir -Filter $DllPattern -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($dll) {
        Copy-Item -Path $dll.FullName -Destination $targetPath -Force
        Write-Host "  [OK] Copied $TargetName" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "  [WARN] $DllPattern not found in $SourceDir" -ForegroundColor Yellow
        return $false
    }
}

# Download Brotli
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 1: Downloading Brotli DLLs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "NOTE: Brotli official releases may not include pre-built Windows DLLs." -ForegroundColor Yellow
Write-Host "Attempting to download from GitHub releases..." -ForegroundColor Yellow

# Try to download Brotli (may fail if no pre-built binaries)
$brotliDir = Download-And-Extract -Url $BrotliUrl -Name "Brotli" -OutputDir $TempDir

if ($brotliDir) {
    # Try to find and copy Brotli DLLs
    Find-And-Copy-DLL -SourceDir $brotliDir -DllPattern "brotlicommon.dll" -TargetName "isbrotlicommon.dll"
    Find-And-Copy-DLL -SourceDir $brotliDir -DllPattern "brotlienc.dll" -TargetName "isbrotlienc.dll"
    Find-And-Copy-DLL -SourceDir $brotliDir -DllPattern "brotlidec.dll" -TargetName "isbrotlidec.dll"
    Find-And-Copy-DLL -SourceDir $brotliDir -DllPattern "brotlicommon.dll" -TargetName "isbrotlicommon-x64.dll"
    Find-And-Copy-DLL -SourceDir $brotliDir -DllPattern "brotlienc.dll" -TargetName "isbrotlienc-x64.dll"
    Find-And-Copy-DLL -SourceDir $brotliDir -DllPattern "brotlidec.dll" -TargetName "isbrotlidec-x64.dll"
}
else {
    Write-Host ""
    Write-Host "[INFO] Brotli pre-built binaries not available from official release." -ForegroundColor Yellow
    Write-Host "Alternative sources:" -ForegroundColor Yellow
    Write-Host "  1. Build from source using build-brotli.bat" -ForegroundColor White
    Write-Host "  2. Download from: https://github.com/google/brotli/releases" -ForegroundColor White
    Write-Host "  3. Use vcpkg: vcpkg install brotli:x86-windows brotli:x64-windows" -ForegroundColor White
}

# Download Zstandard
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Step 2: Downloading Zstandard DLLs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Download 32-bit Zstd
$zstd32Dir = Download-And-Extract -Url $ZstdUrl32 -Name "Zstd32" -OutputDir $TempDir
if ($zstd32Dir) {
    Find-And-Copy-DLL -SourceDir $zstd32Dir -DllPattern "libzstd.dll" -TargetName "iszstd.dll"
    if (-not (Test-Path (Join-Path $FilesDir "iszstd.dll"))) {
        Find-And-Copy-DLL -SourceDir $zstd32Dir -DllPattern "zstd.dll" -TargetName "iszstd.dll"
    }
}

# Download 64-bit Zstd
$zstd64Dir = Download-And-Extract -Url $ZstdUrl64 -Name "Zstd64" -OutputDir $TempDir
if ($zstd64Dir) {
    Find-And-Copy-DLL -SourceDir $zstd64Dir -DllPattern "libzstd.dll" -TargetName "iszstd-x64.dll"
    if (-not (Test-Path (Join-Path $FilesDir "iszstd-x64.dll"))) {
        Find-And-Copy-DLL -SourceDir $zstd64Dir -DllPattern "zstd.dll" -TargetName "iszstd-x64.dll"
    }
}

# Cleanup
Write-Host ""
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  [OK] Cleanup complete" -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Download Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$dlls = @(
    "isbrotlicommon.dll",
    "isbrotlienc.dll",
    "isbrotlidec.dll",
    "isbrotlicommon-x64.dll",
    "isbrotlienc-x64.dll",
    "isbrotlidec-x64.dll",
    "iszstd.dll",
    "iszstd-x64.dll"
)

$foundCount = 0
$missingDlls = @()

foreach ($dll in $dlls) {
    $path = Join-Path $FilesDir $dll
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        Write-Host "  [OK] $dll ($([math]::Round($size/1KB, 2)) KB)" -ForegroundColor Green
        $foundCount++
    }
    else {
        Write-Host "  [MISSING] $dll" -ForegroundColor Red
        $missingDlls += $dll
    }
}

Write-Host ""
Write-Host "Found: $foundCount / $($dlls.Count) DLLs" -ForegroundColor $(if ($foundCount -eq $dlls.Count) { "Green" } else { "Yellow" })

if ($missingDlls.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing DLLs:" -ForegroundColor Yellow
    foreach ($dll in $missingDlls) {
        Write-Host "  - $dll" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Manual download required for missing DLLs:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Brotli:" -ForegroundColor White
    Write-Host "  https://github.com/google/brotli/releases" -ForegroundColor Cyan
    Write-Host "  Or use vcpkg: vcpkg install brotli:x86-windows brotli:x64-windows" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Zstandard:" -ForegroundColor White
    Write-Host "  https://github.com/facebook/zstd/releases" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After downloading, rename and place in:" -ForegroundColor White
    Write-Host "  $FilesDir" -ForegroundColor Cyan
}
else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! All DLLs ready!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Run integration test: TestCompressionIntegration.exe" -ForegroundColor White
    Write-Host "  2. Build Inno Setup with smart compression enabled" -ForegroundColor White
    Write-Host "  3. Test with actual installer compilation" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
