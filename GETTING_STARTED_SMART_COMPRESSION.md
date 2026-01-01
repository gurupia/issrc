# 🚀 Getting Started with Smart Compression Implementation

Welcome to the Inno Setup Smart Compression project! This guide will help you get started with implementing Brotli + Zstandard hybrid compression.

## 📋 Prerequisites

Before you begin, ensure you have:

- [x] **Windows 10/11** (64-bit recommended)
- [x] **Visual Studio 2022** with C++ and CMake support
  - Download: https://visualstudio.microsoft.com/downloads/
  - Required components:
    - Desktop development with C++
    - C++ CMake tools for Windows
- [x] **Git for Windows**
  - Download: https://git-scm.com/download/win
- [x] **Delphi 12.3 Athens** (for Pascal development)
  - Community Edition: https://www.embarcadero.com/products/delphi/starter
- [x] Disk space: ~2GB for libraries and build artifacts

## 🎯 Quick Start (5 Minutes)

### Step 1: Verify Prerequisites

Open PowerShell and verify installations:

```powershell
# Check CMake
cmake --version
# Expected: cmake version 3.25+

# Check Git
git --version
# Expected: git version 2.40+

# Check Visual Studio
where cl
# Expected: Path to Visual Studio compiler
```

### Step 2: Build Compression Libraries

Navigate to the Components directory and run the master build script:

```bash
cd c:\repos\GurupiaInstaller\issrc\Components
build-compression-libs.bat
```

This will:
1. Clone Brotli repository (~10MB)
2. Build Brotli 32-bit and 64-bit DLLs
3. Clone Zstandard repository (~5MB)
4. Build Zstandard 32-bit and 64-bit DLLs
5. Copy DLLs to `Files/` directory
6. Sign DLLs with ISSigTool (if available)

**Estimated time**: 3-5 minutes

### Step 3: Verify Build Output

Check that the following files were created:

```bash
dir ..\Files\isbrotli*.dll
dir ..\Files\iszstd*.dll
```

Expected output:
```
Files/
├── isbrotlicommon.dll       (32-bit)
├── isbrotlienc.dll          (32-bit)
├── isbrotlidec.dll          (32-bit)
├── isbrotlicommon-x64.dll   (64-bit)
├── isbrotlienc-x64.dll      (64-bit)
├── isbrotlidec-x64.dll      (64-bit)
├── iszstd.dll               (32-bit)
└── iszstd-x64.dll           (64-bit)
```

**✅ Phase 1-2 Complete!**

---

## 📚 Development Workflow

### Phase 3: Implement Pascal Bindings (Week 5)

#### Task 3.1: Create Brotli Pascal Wrapper

Create `Projects/Src/Compression.Brotli.pas`:

```pascal
unit Compression.Brotli;

interface

uses
  Windows, SysUtils, Compression.Base;

type
  TBrotliCompressor = class(TCustomCompressor)
  private
    // TODO: Implement Brotli encoder state
  protected
    procedure DoCompress(const Buffer; Count: Cardinal); override;
    procedure DoFinish; override;
  public
    constructor Create(...); override;
    destructor Destroy; override;
  end;

  TBrotliDecompressor = class(TCustomDecompressor)
  private
    // TODO: Implement Brotli decoder state
  public
    procedure DecompressInto(var Buffer; Count: Cardinal); override;
    procedure Reset; override;
  end;

implementation

// TODO: DLL function imports
// function BrotliEncoderCreateInstance: Pointer; cdecl;
//   external 'isbrotlienc.dll';

end.
```

#### Task 3.2: Create Zstandard Pascal Wrapper

Create `Projects/Src/Compression.Zstd.pas`:

```pascal
unit Compression.Zstd;

interface

uses
  Windows, SysUtils, Compression.Base;

type
  TZstdCompressor = class(TCustomCompressor)
  private
    // TODO: Implement Zstd compression context
  protected
    procedure DoCompress(const Buffer; Count: Cardinal); override;
    procedure DoFinish; override;
  public
    constructor Create(...); override;
    destructor Destroy; override;
  end;

  TZstdDecompressor = class(TCustomDecompressor)
  private
    // TODO: Implement Zstd decompression context
  public
    procedure DecompressInto(var Buffer; Count: Cardinal); override;
    procedure Reset; override;
  end;

implementation

// TODO: DLL function imports
// function ZSTD_createCCtx: Pointer; cdecl;
//   external 'iszstd.dll';

end.
```

### Phase 4: Testing (Weeks 8-9)

Create simple test program:

```pascal
program TestCompression;

uses
  Compression.Brotli,
  Compression.Zstd;

procedure TestBrotliRoundTrip;
var
  Original, Compressed, Decompressed: TMemoryStream;
begin
  // TODO: Test compression and decompression
end;

procedure TestZstdRoundTrip;
begin
  // TODO: Test compression and decompression
end;

begin
  TestBrotliRoundTrip;
  TestZstdRoundTrip;
  WriteLn('All tests passed!');
end.
```

---

## 🏗️ Project Structure

```
issrc/
├── SMART_COMPRESSION_ROADMAP.md    ← Master roadmap
├── Components/
│   ├── build-compression-libs.bat  ← Master build script
│   ├── build-brotli.bat           ← Brotli build script
│   ├── build-zstd.bat             ← Zstandard build script
│   ├── README_COMPRESSION.md      ← Library documentation
│   ├── Brotli/                    ← Git submodule (created by script)
│   └── Zstandard/                 ← Git submodule (created by script)
├── Projects/Src/
│   ├── Compression.Base.pas       ← Base classes (existing)
│   ├── Compression.Brotli.pas     ← TODO: Create this
│   ├── Compression.Zstd.pas       ← TODO: Create this
│   └── Compression.SmartSelector.pas ← TODO: Phase 3
└── Files/
    ├── isbrotli*.dll              ← Built by script
    └── iszstd*.dll                ← Built by script
```

---

## 🐛 Troubleshooting

### Problem: "CMake not found"

**Solution**: Install Visual Studio 2022 with C++ CMake tools:
1. Open Visual Studio Installer
2. Click "Modify" on VS 2022
3. Select "Desktop development with C++"
4. Check "C++ CMake tools for Windows"
5. Click "Modify" to install

### Problem: "Git not found"

**Solution**: Install Git for Windows:
```bash
winget install Git.Git
```
or download from https://git-scm.com/download/win

### Problem: Build fails with "Access denied"

**Solution**: Run Command Prompt as Administrator:
1. Right-click Command Prompt
2. Select "Run as administrator"
3. Navigate to Components directory
4. Re-run build script

### Problem: DLLs not created

**Solution**: Check build logs in:
```
Components/Brotli/build-win32/
Components/Brotli/build-x64/
Components/Zstandard/build/cmake/build-win32/
Components/Zstandard/build/cmake/build-x64/
```

Look for error messages in console output.

---

## 📖 Additional Resources

### Documentation
- [Implementation Roadmap](SMART_COMPRESSION_ROADMAP.md) - Detailed 11-week plan
- [Compression Library Docs](Components/README_COMPRESSION.md) - Library details
- [Brotli Specification](https://datatracker.ietf.org/doc/html/rfc7932)
- [Zstandard Specification](https://datatracker.ietf.org/doc/html/rfc8878)

### Source Code
- [Brotli GitHub](https://github.com/google/brotli)
- [Zstandard GitHub](https://github.com/facebook/zstd)
- [Inno Setup Source](https://github.com/jrsoftware/issrc)

### Benchmarks
- [Squash Benchmark](https://quixdb.github.io/squash-benchmark/)
- [Cloudflare Study](https://blog.cloudflare.com/results-experimenting-brotli/)

---

## ✅ Current Status

- [x] **Phase 0**: Planning and documentation
- [x] **Phase 1-2**: Library build infrastructure
- [ ] **Phase 3**: Pascal bindings (Next: Week 5)
- [ ] **Phase 4**: Compiler integration (Week 6-7)
- [ ] **Phase 5**: Testing (Week 8-9)
- [ ] **Phase 6**: Documentation and release (Week 10-11)

**Last Updated**: 2026-01-01  
**Current Phase**: Library Build Complete  
**Next Milestone**: Pascal Bindings (Jan 15, 2026)

---

## 🎉 Success!

If you've completed the Quick Start, you now have:
- ✅ Brotli compression library (6 DLLs)
- ✅ Zstandard compression library (2 DLLs)
- ✅ Build infrastructure ready
- ✅ Foundation for Pascal integration

**Next Steps**:
1. Study existing compression implementations in `Compression.Base.pas`
2. Review Brotli C API at `Components/Brotli/c/include/brotli/encode.h`
3. Review Zstd C API at `Components/Zstandard/lib/zstd.h`
4. Start implementing Pascal bindings (Phase 3)

**Questions?** See [SMART_COMPRESSION_ROADMAP.md](SMART_COMPRESSION_ROADMAP.md) for detailed guidance.

Happy coding! 🚀
