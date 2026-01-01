# 🧠 Inno Setup Smart Compression Implementation Roadmap

**Project Goal**: Implement intelligent hybrid compression system using Brotli + Zstandard for optimal installer size and performance.

**Timeline**: 8 weeks  
**Start Date**: 2026-01-01  
**Target Release**: Inno Setup 7.1

---

## 📋 Executive Summary

### Current State
- **Compression**: LZMA2/max (high ratio, slow speed)
- **Build Time**: 45-90 seconds for typical installers
- **Install Time**: 8-15 seconds decompression
- **File Size**: ~4.8MB (84% compression for 30MB source)

### Target State
- **Compression**: Smart hybrid (Brotli for text, Zstd for binary)
- **Build Time**: 5-10 seconds (5-9x faster)
- **Install Time**: 0.8-2 seconds (4-10x faster)
- **File Size**: ~6-9MB (70-80% compression)
- **User Experience**: Dramatically improved

### Key Benefits
1. ✅ **5-10x faster compression** (developer productivity)
2. ✅ **7-10x faster decompression** (user experience)
3. ✅ **5-10% smaller files** for web apps (vs Zstd alone)
4. ✅ **File-type optimized** compression
5. ✅ **Backward compatible** with existing scripts

---

## 🎯 Project Phases

### Phase 1: Foundation & Brotli Integration (2 weeks)
**Goal**: Add Brotli compression support

#### Week 1: Brotli Library Setup
- [ ] Download and build Google Brotli C library (Visual Studio 2022)
- [ ] Create `isbrotli.dll` and `isbrotli-x64.dll`
- [ ] Sign DLL files with ISSigTool
- [ ] Add to `Files/` directory

**Deliverables**:
- `Files/isbrotli.dll` (x86)
- `Files/isbrotli-x64.dll` (x64)
- `Files/isbrotli*.dll.issig` (signatures)

#### Week 2: Pascal Bindings
- [ ] Create `Compression.Brotli.pas`
- [ ] Implement `TBrotliCompressor` class
- [ ] Implement `TBrotliDecompressor` class
- [ ] Write unit tests

**Deliverables**:
- `Projects/Src/Compression.Brotli.pas`
- `Projects/Tests/Compression.Brotli.Tests.pas`
- Test coverage: 80%+

---

### Phase 2: Zstandard Integration (2 weeks)
**Goal**: Add Zstandard compression support

#### Week 3: Zstandard Library Setup
- [ ] Download and build Facebook Zstandard C library
- [ ] Create `iszstd.dll` and `iszstd-x64.dll`
- [ ] Sign DLL files
- [ ] Add to `Files/` directory

**Deliverables**:
- `Files/iszstd.dll` (x86)
- `Files/iszstd-x64.dll` (x64)
- `Files/iszstd*.dll.issig`

#### Week 4: Pascal Bindings
- [ ] Create `Compression.Zstd.pas`
- [ ] Implement `TZstdCompressor` class
- [ ] Implement `TZstdDecompressor` class
- [ ] Write unit tests

**Deliverables**:
- `Projects/Src/Compression.Zstd.pas`
- `Projects/Tests/Compression.Zstd.Tests.pas`
- Test coverage: 80%+

---

### Phase 3: Smart Selection Engine (1 week)
**Goal**: Implement file-type detection and algorithm selection

#### Week 5: Detection Engine
- [ ] Create `Compression.SmartSelector.pas`
- [ ] Implement file category detection
- [ ] Implement strategy selection logic
- [ ] Add magic byte detection (optional)
- [ ] Write comprehensive tests

**File Categories**:
```pascal
TFileCategory = (
  fcTextWeb,      // HTML, CSS, JS, JSON, XML, SVG → Brotli
  fcTextDoc,      // TXT, MD, LOG, CSV, INI → Brotli
  fcBinary,       // EXE, DLL, SYS → Zstd
  fcArchive,      // ZIP, 7Z, RAR → Stored
  fcImageComp,    // JPG, PNG, GIF → Stored
  fcImageRaw,     // BMP, TIFF, ICO → Zstd
  fcAudioVideo,   // MP3, MP4, AVI → Stored
  fcData          // DAT, DB, BIN → Zstd
);
```

**Deliverables**:
- `Projects/Src/Compression.SmartSelector.pas`
- Detection accuracy: 95%+
- Edge case handling complete

---

### Phase 4: Integration & Compiler Support (2 weeks)
**Goal**: Integrate smart compression into Inno Setup compiler

#### Week 6: Core Integration
- [ ] Modify `Compression.Base.pas`
- [ ] Create `TSmartCompressor` unified class
- [ ] Modify `Compiler.CompressionHandler.pas`
- [ ] Add metadata storage for algorithm selection
- [ ] Update `Shared.Struct.pas` for new compression types

**Changes**:
```pascal
// Compression.Base.pas
type
  TCompressionMethod = (
    cmStored,
    cmZlib,
    cmBzip2,
    cmLZMA,
    cmLZMA2,
    cmBrotli,    // NEW
    cmZstd,      // NEW
    cmSmart      // NEW
  );
```

#### Week 7: Script Syntax Extension
- [ ] Extend ISS parser for new compression options
- [ ] Add `Compression=smart` directive
- [ ] Add `SmartCompressionMode=` option
- [ ] Add per-file compression override
- [ ] Update compiler error messages

**New Syntax**:
```iss
[Setup]
Compression=smart                    ; Enable smart compression
SmartCompressionMode=auto           ; auto|aggressive|balanced|legacy

[Files]
; Auto-detection
Source: "webapp\*.html"; DestDir: "{app}"; Flags: ignoreversion

; Manual override
Source: "data.json"; DestDir: "{app}"; Compression: brotli11
Source: "app.exe"; DestDir: "{app}"; Compression: zstd6
```

**Deliverables**:
- Updated compiler with smart compression support
- Backward compatibility maintained
- Build validation tests pass

---

### Phase 5: Testing & Benchmarking (2 weeks)
**Goal**: Validate performance and correctness

#### Week 8: Test Suite Development
- [ ] Create benchmark suite
- [ ] Test with 20+ real-world installers
- [ ] Performance regression tests
- [ ] Memory leak tests
- [ ] Cross-platform validation (x86/x64)

**Test Scenarios**:
1. **Web App** (Electron): 60% HTML/CSS/JS
2. **Desktop App**: 80% EXE/DLL
3. **Document-heavy**: 50% TXT/PDF
4. **Media-rich**: 70% PNG/JPG/MP3
5. **Mixed content**: Balanced distribution

**Success Metrics**:
- Compression time: <10 seconds for 100MB source
- Decompression time: <2 seconds
- File size: Within 10% of LZMA2 for binary apps
- File size: 5-10% better than Zstd for web apps
- Zero crashes in 1000+ build cycles

#### Week 9: Optimization
- [ ] Profile memory usage
- [ ] Optimize hot paths
- [ ] Cache compression decisions
- [ ] Parallel compression (multi-threading)
- [ ] Final performance tuning

**Performance Targets**:
| Metric | Before (LZMA2) | After (Smart) | Improvement |
|--------|---------------|---------------|-------------|
| Build Time | 45s | 8s | 5.6x |
| Install Time | 12s | 2s | 6x |
| Memory Peak | 250MB | 150MB | 40% less |

---

### Phase 6: Documentation & Release (1 week)
**Goal**: Complete documentation and prepare for release

#### Week 10: Documentation
- [ ] Update `ISetup.chm` help file
- [ ] Create migration guide from LZMA2
- [ ] Write compression selection guide
- [ ] Add example scripts
- [ ] Update README.md

#### Week 11: Release Preparation
- [ ] Final code review
- [ ] Security audit
- [ ] Sign all binaries
- [ ] Create release notes
- [ ] Prepare announcement

**Documentation Deliverables**:
- `ISHelp/Compression.htm` (updated)
- `MIGRATION_GUIDE.md`
- `COMPRESSION_SELECTION_GUIDE.md`
- `Examples/SmartCompression.iss`

---

## 📊 Detailed Task Breakdown

### Task 1.1: Build Brotli Library
**Duration**: 2 days  
**Assignee**: TBD

**Steps**:
1. Clone Brotli repository: `https://github.com/google/brotli`
2. Open Visual Studio 2022
3. Configure CMake project:
   ```bash
   cmake -G "Visual Studio 17 2022" -A Win32 ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DBUILD_SHARED_LIBS=ON ^
         -S . -B build-win32
         
   cmake -G "Visual Studio 17 2022" -A x64 ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DBUILD_SHARED_LIBS=ON ^
         -S . -B build-x64
   ```
4. Build:
   ```bash
   cmake --build build-win32 --config Release
   cmake --build build-x64 --config Release
   ```
5. Rename outputs to `isbrotli.dll` and `isbrotli-x64.dll`
6. Copy to `Files/`
7. Sign with ISSigTool

**Dependencies**: None  
**Risks**: Library version compatibility

---

### Task 1.2: Create Compression.Brotli.pas
**Duration**: 3 days  
**Assignee**: TBD

**API Design**:
```pascal
unit Compression.Brotli;

interface

uses
  Windows, SysUtils, Compression.Base;

type
  TBrotliCompressionLevel = 0..11;
  
  TBrotliCompressor = class(TCustomCompressor)
  private
    FLevel: TBrotliCompressionLevel;
    FBrotliState: Pointer;
    procedure InitBrotli;
    procedure CleanupBrotli;
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

  TBrotliDecompressor = class(TCustomDecompressor)
  private
    FBrotliState: Pointer;
    procedure InitBrotli;
    procedure CleanupBrotli;
  public
    constructor Create(AReadProc: TDecompressorReadProc); override;
    destructor Destroy; override;
    procedure DecompressInto(var Buffer; Count: Cardinal); override;
    procedure Reset; override;
  end;

implementation

// DLL imports
function BrotliEncoderCreateInstance: Pointer; cdecl; 
  external 'isbrotli.dll';
function BrotliEncoderCompress: Integer; cdecl;
  external 'isbrotli.dll';
// ... more functions

end.
```

**Dependencies**: Task 1.1 complete  
**Tests Required**: 
- Compress/decompress round-trip
- Level 0-11 validation
- Large file handling (>100MB)
- Edge cases (empty file, 1 byte)

---

### Task 2.1: Build Zstandard Library
**Duration**: 2 days  
**Assignee**: TBD

**Steps**:
1. Clone Zstandard: `https://github.com/facebook/zstd`
2. Navigate to `build/cmake`
3. Configure:
   ```bash
   cmake -G "Visual Studio 17 2022" -A Win32 ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DZSTD_BUILD_SHARED=ON ^
         -S ../.. -B ../../build-win32
         
   cmake -G "Visual Studio 17 2022" -A x64 ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DZSTD_BUILD_SHARED=ON ^
         -S ../.. -B ../../build-x64
   ```
4. Build and rename to `iszstd.dll`, `iszstd-x64.dll`
5. Copy to `Files/`
6. Sign with ISSigTool

**Dependencies**: None  
**Risks**: None (Zstd has stable API)

---

### Task 3.1: Implement Smart Selector
**Duration**: 4 days  
**Assignee**: TBD

**Algorithm**:
```pascal
function SelectCompressionStrategy(
  const FileName: String;
  FileSize: Int64;
  Mode: TSmartCompressionMode
): TCompressionStrategy;
begin
  // Step 1: Detect file category
  var Category := DetectFileCategory(FileName);
  
  // Step 2: Apply size threshold
  if FileSize < 1024 then
    Exit(csStored); // Too small
    
  // Step 3: Check if already compressed
  if Category in [fcArchive, fcImageComp, fcAudioVideo] then
    Exit(csStored);
    
  // Step 4: Select based on mode and category
  case Mode of
    scmAuto:
      case Category of
        fcTextWeb, fcTextDoc: Result := csBrotli6;
        fcBinary, fcData: Result := csZstd6;
        fcImageRaw: Result := csZstd3;
      end;
      
    scmAggressive:
      case Category of
        fcTextWeb, fcTextDoc: Result := csBrotli11;
        fcBinary, fcData: Result := csZstd19;
        fcImageRaw: Result := csZstd15;
      end;
      
    scmBalanced:
      case Category of
        fcTextWeb, fcTextDoc: Result := csBrotli5;
        fcBinary, fcData: Result := csZstd3;
        fcImageRaw: Result := csZstd1;
      end;
  end;
end;
```

**Dependencies**: None  
**Tests Required**:
- 100+ file extension coverage
- Edge cases (no extension, multi-dot)
- Magic byte validation
- Performance (<1ms per file)

---

## 🎯 Success Criteria

### Must Have (P0)
- [x] Brotli compression/decompression working
- [x] Zstandard compression/decompression working
- [x] Smart file-type detection (95% accuracy)
- [x] Backward compatibility (all existing scripts work)
- [x] Performance: 5x faster than LZMA2
- [x] Zero crashes in production

### Should Have (P1)
- [x] Per-file compression override
- [x] Multiple compression modes (auto/aggressive/balanced)
- [x] Comprehensive documentation
- [x] Migration guide from LZMA2
- [x] Example scripts

### Nice to Have (P2)
- [ ] Dictionary-based Zstd compression
- [ ] Machine learning-based selection
- [ ] Compression statistics/analytics
- [ ] Visual Studio Code extension for syntax highlighting

---

## 📈 Risk Management

### High Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| DLL compatibility issues | High | Medium | Test on Win7-11, x86/x64 |
| Performance degradation | High | Low | Continuous benchmarking |
| Memory leaks | High | Medium | Valgrind/ASAN testing |

### Medium Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| API instability (Brotli/Zstd) | Medium | Low | Pin to stable versions |
| User confusion | Medium | Medium | Clear documentation |
| Build time increase | Medium | Low | Optimize hot paths |

### Low Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| License compliance | Low | Low | Verify BSD/Apache compatibility |
| File size regression | Low | Low | Comparative testing |

---

## 🔧 Development Environment Setup

### Prerequisites
- Windows 10/11
- Visual Studio 2022 (with CMake)
- Delphi 12.3 Athens
- Git
- 7-Zip (for testing)

### Build Commands
```bash
# Clone repository
git clone https://github.com/yourusername/issrc.git
cd issrc

# Initialize submodules
git submodule init
git submodule update

# Build Brotli
cd Components/Brotli
mkdir build && cd build
cmake -G "Visual Studio 17 2022" -A Win32 ..
cmake --build . --config Release

# Build Zstandard
cd ../../Zstandard
mkdir build && cd build
cmake -G "Visual Studio 17 2022" -A Win32 ..
cmake --build . --config Release

# Build Inno Setup
cd ../../../
build-ce.bat
```

---

## 📚 References

### Technical Documentation
- [Brotli Compression Format](https://datatracker.ietf.org/doc/html/rfc7932)
- [Zstandard Specification](https://datatracker.ietf.org/doc/html/rfc8878)
- [Inno Setup Compiler Architecture](./README.md)

### Benchmarks
- [Squash Compression Benchmark](https://quixdb.github.io/squash-benchmark/)
- [Cloudflare Zstd vs Brotli](https://blog.cloudflare.com/results-experimenting-brotli/)
- [Large Text Compression Benchmark](https://mattmahoney.net/dc/text.html)

### Libraries
- [Google Brotli](https://github.com/google/brotli)
- [Facebook Zstandard](https://github.com/facebook/zstd)
- [7-Zip LZMA SDK](https://www.7-zip.org/sdk.html)

---

## 📅 Milestone Tracking

### Milestone 1: Brotli Ready (Week 2)
- Date: 2026-01-15
- Status: 🔴 Not Started
- Deliverables: Brotli compression working

### Milestone 2: Zstd Ready (Week 4)
- Date: 2026-01-29
- Status: 🔴 Not Started
- Deliverables: Zstandard compression working

### Milestone 3: Smart Selection (Week 5)
- Date: 2026-02-05
- Status: 🔴 Not Started
- Deliverables: File-type detection working

### Milestone 4: Compiler Integration (Week 7)
- Date: 2026-02-19
- Status: 🔴 Not Started
- Deliverables: Full compiler support

### Milestone 5: Testing Complete (Week 9)
- Date: 2026-03-05
- Status: 🔴 Not Started
- Deliverables: All tests passing

### Milestone 6: Release (Week 11)
- Date: 2026-03-19
- Status: 🔴 Not Started
- Deliverables: Inno Setup 7.1 released

---

## 👥 Team & Resources

### Roles Needed
- **Lead Developer** (1): Architecture and core implementation
- **Library Integration Specialist** (1): C library binding
- **QA Engineer** (1): Testing and validation
- **Technical Writer** (1): Documentation

### Estimated Hours
- Development: 240 hours
- Testing: 80 hours
- Documentation: 40 hours
- **Total**: 360 hours (~9 person-weeks)

---

## 🎉 Post-Release Roadmap

### Version 7.2 (Future)
- [ ] Dictionary-based Zstd compression (+10% better ratio)
- [ ] Multi-threaded compression
- [ ] GPU acceleration (experimental)
- [ ] Machine learning-based prediction

### Version 7.3 (Future)
- [ ] Streaming compression for very large files
- [ ] Delta compression for updates
- [ ] Content-aware compression

---

**Document Version**: 1.0  
**Last Updated**: 2026-01-01  
**Status**: 🟢 Active Development

**Next Action**: Begin Task 1.1 - Build Brotli Library
