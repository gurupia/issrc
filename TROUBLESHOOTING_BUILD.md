# 🔧 Smart Compression - Alternative Setup Guide

## ⚠️ Build Issues Troubleshooting

If you're experiencing build errors with CMake, here are alternative approaches:

---

## Option 1: Use Pre-built Binaries (Fastest)

### Brotli Pre-built DLLs

Download from official sources:

1. **Visit**: https://github.com/google/brotli/releases
2. **Download**: Latest Windows release (e.g., `brotli-v1.1.0-win-x64.zip`)
3. **Extract** and rename:
   - `brotlicommon.dll` → `isbrotlicommon.dll`
   - `brotlienc.dll` → `isbrotlienc.dll`
   - `brotlidec.dll` → `isbrotlidec.dll`
4. **Copy** to `c:\repos\GurupiaInstaller\issrc\Files\`

### Zstandard Pre-built DLLs

1. **Visit**: https://github.com/facebook/zstd/releases
2. **Download**: `zstd-v1.5.5-win64.zip` and `zstd-v1.5.5-win32.zip`
3. **Extract** and rename:
   - `zstd.dll` → `iszstd.dll` (32-bit)
   - `zstd.dll` → `iszstd-x64.dll` (64-bit)
4. **Copy** to `c:\repos\GurupiaInstaller\issrc\Files\`

---

## Option 2: Direct Implementation (Skip Build)

You can start implementing the Pascal bindings without building the libraries first:

### Step 1: Create Pascal Interface

Create `Projects\Src\Compression.Brotli.pas`:

```pascal
unit Compression.Brotli;

interface

uses
  Windows, SysUtils, Compression.Base;

const
  // Brotli compression levels: 0 (fast) to 11 (max)
  BROTLI_MIN_QUALITY = 0;
  BROTLI_MAX_QUALITY = 11;
  BROTLI_DEFAULT_QUALITY = 6;

type
  TBrotliCompressionQuality = BROTLI_MIN_QUALITY..BROTLI_MAX_QUALITY;

  TBrotliCompressor = class(TCustomCompressor)
  private
    FQuality: TBrotliCompressionQuality;
    FState: Pointer;
  protected
    procedure DoCompress(const Buffer; Count: Cardinal); override;
    procedure DoFinish; override;
  public
    constructor Create(AWriteProc: TCompressorWriteProc;
      AProgressProc: TCompressorProgressProc;
      CompressionLevel: Integer;
      ACompressorProps: TCompressorProps); override;
    destructor Destroy; override;
  end;

implementation

// DLL imports will be added here once DLLs are available

constructor TBrotliCompressor.Create(...);
begin
  inherited Create(AWriteProc, AProgressProc, CompressionLevel, ACompressorProps);
  
  // Map generic compression level (0-9) to Brotli quality (0-11)
  if CompressionLevel <= 0 then
    FQuality := BROTLI_MIN_QUALITY
  else if CompressionLevel >= 9 then
    FQuality := BROTLI_MAX_QUALITY
  else
    FQuality := (CompressionLevel * 11) div 9;
end;

destructor TBrotliCompressor.Destroy;
begin
  // TODO: Cleanup Brotli state
  inherited;
end;

procedure TBrotliCompressor.DoCompress(const Buffer; Count: Cardinal);
begin
  // TODO: Call Brotli compression API
end;

procedure TBrotliCompressor.DoFinish;
begin
  // TODO: Finalize Brotli compression
end;

end.
```

### Step 2: Design Smart Selector

Create `Projects\Src\Compression.SmartSelector.pas` (see roadmap for full implementation).

---

## Option 3: Fix Visual Studio Environment

### Check Visual Studio Installation

```powershell
# Find Visual Studio
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath

# Set environment for CMake
$vsPath = & "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
& "$vsPath\Common7\Tools\Launch-VsDevShell.ps1"

# Then try building
cd c:\repos\GurupiaInstaller\issrc\Components
.\build-brotli.bat
```

### Manual CMake Build

```powershell
# Navigate to Components
cd c:\repos\GurupiaInstaller\issrc\Components

# Clone Brotli
git clone --depth 1 https://github.com/google/brotli.git Brotli
cd Brotli

# Create build directory
mkdir build
cd build

# Configure with CMake
cmake -G "Visual Studio 17 2022" -A Win32 ..
cmake --build . --config Release

# DLLs will be in: Release\brotli*.dll
```

---

## Option 4: Proceed Without Building (Documentation Focus)

You can still make progress without compiled libraries:

### ✅ What You Can Do Now:

1. **Study Existing Code**
   - Analyze `Compression.Base.pas`
   - Study `Compression.LZMACompressor.pas`
   - Understand the compression interface

2. **Design Architecture**
   - Plan smart selection algorithm
   - Define file type categories
   - Design API interfaces

3. **Write Documentation**
   - Pascal API documentation
   - Usage examples
   - Integration guide

4. **Create Test Cases**
   - Define test scenarios
   - Prepare test data
   - Write test framework

---

## Current Status

### ✅ Completed
- [x] Roadmap documentation
- [x] Build scripts created
- [x] Getting started guide
- [x] Architecture planning

### ⏸️ Pending (Build Issues)
- [ ] Brotli DLLs (can use pre-built)
- [ ] Zstandard DLLs (can use pre-built)
- [ ] DLL signing

### 🎯 Next Steps (Not Blocked)
- [ ] Pascal bindings design
- [ ] Smart selector algorithm
- [ ] Unit test framework
- [ ] Documentation

---

## Recommended Path Forward

Given the build issues, I recommend **Option 1** (pre-built binaries):

1. Download pre-built Bprotli and Zstd DLLs
2. Rename and copy to `Files/` directory
3. Sign with ISSigTool
4. Proceed with Pascal implementation

This will save time and allow you to focus on the actual compression logic rather than build environment issues.

---

## Need Help?

### Check Environment
```powershell
# Verify tools
cmake --version
git --version
cl.exe 2>&1 | Select-String "Microsoft"

# Check Visual Studio installation
Get-Command devenv -ErrorAction SilentlyContinue
```

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| "CMake not found" | CMake not in PATH | Install VS 2022 with CMake |
| "Generator not found" | Visual Studio not detected | Run from VS Developer Command Prompt |
| "Access denied" | Permissions | Run as Administrator |
| Build hangs | Network issue (git clone) | Use `--depth 1` for shallow clone |

---

**Updated**: 2026-01-01  
**Status**: Build Issues - Workaround Available  
**Recommendation**: Use pre-built binaries or skip to Pascal implementation

Would you like me to proceed with Option 1 (pre-built binaries) or Option 2 (Pascal implementation without libraries)?
