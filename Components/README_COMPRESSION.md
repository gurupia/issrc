# Compression Libraries for Inno Setup

This directory contains the compression algorithm implementations used by Inno Setup.

## Current Algorithms

### LZMA2 (Existing)
- **Location**: `Components/Lzma2/`
- **Library**: 7-Zip LZMA SDK
- **License**: Public Domain
- **Usage**: High compression ratio, slower speed

## New Algorithms (Smart Compression)

### Brotli
- **Location**: `Components/Brotli/` (to be created)
- **Library**: Google Brotli
- **Version**: 1.1.0+
- **License**: MIT
- **Best For**: Text files (HTML, CSS, JS, JSON, XML)
- **Compression Ratio**: 15-25% better than Gzip for web content
- **Speed**: Moderate compression, fast decompression

### Zstandard (Zstd)
- **Location**: `Components/Zstandard/` (to be created)
- **Library**: Facebook Zstandard
- **Version**: 1.5.5+
- **License**: BSD + GPLv2 dual license
- **Best For**: Binary files, general purpose
- **Compression Ratio**: Similar to LZMA at high levels
- **Speed**: 5-10x faster compression, 7-10x faster decompression than LZMA2

## Building Instructions

### Prerequisites
- Windows 10/11
- Visual Studio 2022 with CMake support
- Git

### Build Brotli
```bash
cd Components
git clone https://github.com/google/brotli.git Brotli
cd Brotli

# Build 32-bit
cmake -G "Visual Studio 17 2022" -A Win32 ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_SHARED_LIBS=ON ^
      -S . -B build-win32
cmake --build build-win32 --config Release

# Build 64-bit
cmake -G "Visual Studio 17 2022" -A x64 ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_SHARED_LIBS=ON ^
      -S . -B build-x64
cmake --build build-x64 --config Release

# Copy outputs
copy build-win32\Release\brotlienc.dll ..\..\Files\isbrotli.dll
copy build-x64\Release\brotlienc.dll ..\..\Files\isbrotli-x64.dll
```

### Build Zstandard
```bash
cd Components
git clone https://github.com/facebook/zstd.git Zstandard
cd Zstandard\build\cmake

# Build 32-bit
cmake -G "Visual Studio 17 2022" -A Win32 ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DZSTD_BUILD_SHARED=ON ^
      -DZSTD_BUILD_STATIC=OFF ^
      -S . -B build-win32
cmake --build build-win32 --config Release

# Build 64-bit
cmake -G "Visual Studio 17 2022" -A x64 ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DZSTD_BUILD_SHARED=ON ^
      -DZSTD_BUILD_STATIC=OFF ^
      -S . -B build-x64
cmake --build build-x64 --config Release

# Copy outputs
copy build-win32\lib\Release\zstd.dll ..\..\..\Files\iszstd.dll
copy build-x64\lib\Release\zstd.dll ..\..\..\Files\iszstd-x64.dll
```

### Sign DLLs
```bash
cd Files
..\ISSigTool.exe sign isbrotli.dll
..\ISSigTool.exe sign isbrotli-x64.dll
..\ISSigTool.exe sign iszstd.dll
..\ISSigTool.exe sign iszstd-x64.dll
```

## Integration Status

- [x] LZMA2 - Production
- [ ] Brotli - In Development (Phase 1)
- [ ] Zstandard - In Development (Phase 2)
- [ ] Smart Selection - Planned (Phase 3)

## Performance Comparison

| Algorithm | Compression Ratio | Compression Speed | Decompression Speed | Best Use Case |
|-----------|------------------|-------------------|---------------------|---------------|
| **LZMA2** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ | Maximum compression |
| **Brotli** | ⭐⭐⭐⭐⭐ (text) | ⭐⭐⭐ | ⭐⭐⭐⭐ | Web content |
| **Zstd** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | General purpose |

## License Compatibility

All compression libraries are compatible with Inno Setup's license:
- **LZMA2**: Public Domain
- **Brotli**: MIT License
- **Zstandard**: BSD License (or GPLv2, we use BSD)

## References

- [SMART_COMPRESSION_ROADMAP.md](../SMART_COMPRESSION_ROADMAP.md) - Implementation roadmap
- [Brotli GitHub](https://github.com/google/brotli)
- [Zstandard GitHub](https://github.com/facebook/zstd)
- [Compression Benchmark](https://quixdb.github.io/squash-benchmark/)
