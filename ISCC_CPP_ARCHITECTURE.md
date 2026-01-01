# ISCC.exe C++ 포팅 아키텍처 설계

**작성일**: 2026-01-01 20:48  
**목적**: ISCC.exe만 C++로 포팅하는 구조 설계  
**상태**: 설계 문서

---

## 🎯 **설계 목표**

### **핵심 원칙**

```
1. 호환성: 기존 ISCC.exe와 100% 호환
2. 단순성: 명확한 모듈 구조
3. 확장성: 새 기능 추가 용이
4. 성능: 기존보다 빠르게
5. 유지보수: 읽기 쉬운 코드
```

---

## 📊 **전체 아키텍처**

### **레이어 구조**

```
┌─────────────────────────────────────┐
│   CLI Layer (main.cpp)              │
│   - 명령줄 파싱                      │
│   - 옵션 처리                        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Compiler Layer                    │
│   - ScriptCompiler                  │
│   - SetupBuilder                    │
└──────────────┬──────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼──────┐  ┌─────▼──────┐
│   Parser    │  │ Compression│
│   - ISS     │  │ - Smart    │
│   - AST     │  │ - Brotli   │
└──────┬──────┘  │ - Zstd     │
       │         └─────┬──────┘
       │                │
┌──────▼────────────────▼──────┐
│   Core Library               │
│   - FileSystem               │
│   - String Utils             │
│   - Crypto                   │
└──────────────────────────────┘
```

---

## 🗂️ **디렉토리 구조**

```
iscc-cpp/
├── CMakeLists.txt
├── README.md
│
├── src/
│   ├── main.cpp                    # 진입점
│   │
│   ├── cli/
│   │   ├── CommandLine.h/cpp       # 명령줄 파서
│   │   └── Options.h/cpp           # 옵션 관리
│   │
│   ├── compiler/
│   │   ├── Compiler.h/cpp          # 메인 컴파일러
│   │   ├── ScriptParser.h/cpp      # ISS 파서
│   │   ├── SetupBuilder.h/cpp      # Setup.exe 빌더
│   │   └── AST.h/cpp               # 추상 구문 트리
│   │
│   ├── compression/
│   │   ├── Compressor.h/cpp        # 압축 인터페이스
│   │   ├── BrotliCompressor.h/cpp  # Brotli 구현
│   │   ├── ZstdCompressor.h/cpp    # Zstd 구현
│   │   ├── LzmaCompressor.h/cpp    # LZMA 구현
│   │   ├── SmartSelector.h/cpp     # Smart 선택
│   │   └── Factory.h/cpp           # 팩토리
│   │
│   ├── core/
│   │   ├── FileSystem.h/cpp        # 파일 시스템
│   │   ├── String.h/cpp            # 문자열 유틸
│   │   ├── Crypto.h/cpp            # 암호화
│   │   └── Error.h/cpp             # 에러 처리
│   │
│   └── stub/
│       └── StubLoader.h/cpp        # 스텁 로더
│
├── include/
│   └── iscc/                       # 공개 헤더
│
├── tests/
│   ├── unit/                       # 단위 테스트
│   └── integration/                # 통합 테스트
│
└── third_party/
    ├── brotli/
    ├── zstd/
    ├── lzma/
    └── nlohmann_json/
```

---

## 💻 **핵심 클래스 설계**

### **1. CommandLine (CLI)**

```cpp
// cli/CommandLine.h
#pragma once
#include <string>
#include <vector>
#include <optional>

namespace iscc::cli {

struct Options {
    std::string scriptFile;
    std::optional<std::string> outputDir;
    bool quiet = false;
    bool verbose = false;
    std::vector<std::string> defines;
};

class CommandLine {
public:
    static Options parse(int argc, char* argv[]);
    static void printUsage();
    static void printVersion();
    
private:
    static void validateOptions(const Options& opts);
};

} // namespace iscc::cli
```

**사용 예**:
```cpp
// main.cpp
int main(int argc, char* argv[]) {
    try {
        auto opts = CommandLine::parse(argc, argv);
        Compiler compiler(opts);
        return compiler.compile();
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        return 1;
    }
}
```

---

### **2. ScriptParser (ISS 파서)**

```cpp
// compiler/ScriptParser.h
#pragma once
#include <string>
#include <memory>
#include "AST.h"

namespace iscc::compiler {

class ScriptParser {
public:
    explicit ScriptParser(const std::string& filename);
    
    std::unique_ptr<AST> parse();
    
private:
    std::string filename_;
    std::string content_;
    size_t pos_ = 0;
    
    void parseSetupSection(AST& ast);
    void parseFilesSection(AST& ast);
    void parseRegistrySection(AST& ast);
    void parseSection(const std::string& name, AST& ast);
    
    std::string readLine();
    std::string readUntil(char delimiter);
    void skipWhitespace();
};

} // namespace iscc::compiler
```

**사용 예**:
```cpp
ScriptParser parser("setup.iss");
auto ast = parser.parse();

// AST 사용
for (const auto& file : ast->files) {
    std::cout << "File: " << file.source << "\n";
}
```

---

### **3. AST (추상 구문 트리)**

```cpp
// compiler/AST.h
#pragma once
#include <string>
#include <vector>
#include <map>

namespace iscc::compiler {

struct SetupSection {
    std::string appName;
    std::string appVersion;
    std::string defaultDirName;
    std::string compression = "lzma2";
    std::string smartMode = "auto";
    // ... 기타 필드
};

struct FileEntry {
    std::string source;
    std::string destDir;
    std::string destName;
    std::map<std::string, std::string> flags;
};

struct RegistryEntry {
    std::string root;
    std::string subkey;
    std::string valueName;
    std::string valueData;
};

struct AST {
    SetupSection setup;
    std::vector<FileEntry> files;
    std::vector<RegistryEntry> registry;
    // ... 기타 섹션
};

} // namespace iscc::compiler
```

---

### **4. Compressor (압축 인터페이스)**

```cpp
// compression/Compressor.h
#pragma once
#include <vector>
#include <cstdint>
#include <memory>

namespace iscc::compression {

enum class CompressionMethod {
    Stored,
    Zlib,
    Bzip2,
    LZMA,
    LZMA2,
    Brotli,
    Zstd,
    Smart
};

class Compressor {
public:
    virtual ~Compressor() = default;
    
    virtual std::vector<uint8_t> compress(
        const std::vector<uint8_t>& data
    ) = 0;
    
    virtual void setLevel(int level) = 0;
    virtual CompressionMethod getMethod() const = 0;
};

// 팩토리
class CompressorFactory {
public:
    static std::unique_ptr<Compressor> create(
        CompressionMethod method,
        const std::string& filename = ""
    );
};

} // namespace iscc::compression
```

---

### **5. SmartSelector (Smart 압축)**

```cpp
// compression/SmartSelector.h
#pragma once
#include <string>
#include "Compressor.h"

namespace iscc::compression {

enum class FileCategory {
    TextWeb,      // HTML, CSS, JS
    TextDoc,      // TXT, XML, JSON
    Binary,       // EXE, DLL
    Archive,      // ZIP, RAR
    ImageComp,    // JPG, PNG
    ImageRaw,     // BMP, TGA
    AudioVideo,   // MP3, MP4
    Data,         // DAT, DB
    Unknown
};

enum class SmartMode {
    Auto,
    Aggressive,
    Balanced,
    Fast
};

struct CompressionStrategy {
    CompressionMethod method;
    int level;
};

class SmartSelector {
public:
    static FileCategory detectCategory(const std::string& filename);
    
    static CompressionStrategy selectStrategy(
        FileCategory category,
        size_t fileSize,
        SmartMode mode = SmartMode::Auto
    );
    
private:
    static std::string getExtension(const std::string& filename);
};

} // namespace iscc::compression
```

**구현 예**:
```cpp
// compression/SmartSelector.cpp
CompressionStrategy SmartSelector::selectStrategy(
    FileCategory category,
    size_t fileSize,
    SmartMode mode
) {
    // 매우 작은 파일
    if (fileSize < 1024) {
        return {CompressionMethod::Stored, 0};
    }
    
    // 카테고리별 전략
    switch (category) {
        case FileCategory::TextWeb:
            return {CompressionMethod::Brotli, 6};
            
        case FileCategory::Binary:
            return {CompressionMethod::Zstd, 6};
            
        case FileCategory::Archive:
        case FileCategory::ImageComp:
        case FileCategory::AudioVideo:
            return {CompressionMethod::Stored, 0};
            
        default:
            return {CompressionMethod::LZMA2, 2};
    }
}
```

---

### **6. SetupBuilder (Setup.exe 생성)**

```cpp
// compiler/SetupBuilder.h
#pragma once
#include <string>
#include <memory>
#include "AST.h"
#include "../compression/Compressor.h"

namespace iscc::compiler {

class SetupBuilder {
public:
    explicit SetupBuilder(const AST& ast);
    
    void build(const std::string& outputPath);
    
private:
    const AST& ast_;
    std::unique_ptr<compression::Compressor> compressor_;
    
    void loadStub();
    void compressFiles();
    void writeHeader();
    void writeData();
    void createExecutable();
    
    std::vector<uint8_t> stubData_;
    std::vector<uint8_t> compressedData_;
};

} // namespace iscc::compiler
```

**사용 예**:
```cpp
SetupBuilder builder(ast);
builder.build("Output/Setup.exe");
```

---

## 🔧 **빌드 시스템 (CMake)**

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(iscc-cpp VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 옵션
option(BUILD_TESTS "Build tests" ON)
option(USE_SYSTEM_LIBS "Use system libraries" OFF)

# 서드파티 라이브러리
find_package(ZSTD REQUIRED)
find_package(BZip2 REQUIRED)

# 소스 파일
add_executable(iscc
    src/main.cpp
    src/cli/CommandLine.cpp
    src/cli/Options.cpp
    src/compiler/Compiler.cpp
    src/compiler/ScriptParser.cpp
    src/compiler/SetupBuilder.cpp
    src/compiler/AST.cpp
    src/compression/Compressor.cpp
    src/compression/BrotliCompressor.cpp
    src/compression/ZstdCompressor.cpp
    src/compression/LzmaCompressor.cpp
    src/compression/SmartSelector.cpp
    src/compression/Factory.cpp
    src/core/FileSystem.cpp
    src/core/String.cpp
    src/core/Crypto.cpp
    src/core/Error.cpp
    src/stub/StubLoader.cpp
)

# 링크
target_link_libraries(iscc
    PRIVATE
        ZSTD::ZSTD
        BZip2::BZip2
        brotlienc
        brotlidec
)

# 테스트
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
```

---

## 🧪 **테스트 구조**

```cpp
// tests/unit/test_smart_selector.cpp
#include <gtest/gtest.h>
#include "compression/SmartSelector.h"

using namespace iscc::compression;

TEST(SmartSelector, DetectTextWeb) {
    EXPECT_EQ(
        SmartSelector::detectCategory("index.html"),
        FileCategory::TextWeb
    );
    
    EXPECT_EQ(
        SmartSelector::detectCategory("style.css"),
        FileCategory::TextWeb
    );
}

TEST(SmartSelector, SelectStrategyForText) {
    auto strategy = SmartSelector::selectStrategy(
        FileCategory::TextWeb,
        10240,
        SmartMode::Auto
    );
    
    EXPECT_EQ(strategy.method, CompressionMethod::Brotli);
    EXPECT_EQ(strategy.level, 6);
}

TEST(SmartSelector, SelectStrategyForBinary) {
    auto strategy = SmartSelector::selectStrategy(
        FileCategory::Binary,
        10240,
        SmartMode::Auto
    );
    
    EXPECT_EQ(strategy.method, CompressionMethod::Zstd);
}
```

---

## 📊 **데이터 흐름**

```
1. main.cpp
   ↓ CommandLine::parse()
   
2. Options
   ↓ Compiler::compile()
   
3. ScriptParser
   ↓ parse()
   
4. AST
   ↓ SetupBuilder::build()
   
5. Compression
   ↓ SmartSelector::select()
   
6. Compressor
   ↓ compress()
   
7. Setup.exe
```

---

## 🎯 **호환성 보장**

### **명령줄 호환**

```cpp
// 기존 ISCC.exe와 동일
iscc script.iss
iscc /O"output" script.iss
iscc /Q script.iss
iscc /D"MyDefine=Value" script.iss
```

### **출력 형식 호환**

```cpp
// 동일한 메시지 형식
std::cout << "Inno Setup 5 Command-Line Compiler\n";
std::cout << "Copyright (C) 1997-2024 Jordan Russell\n";
std::cout << "\n";
std::cout << "Compiling " << scriptFile << "...\n";
std::cout << "Successful compile (1.234 sec)\n";
```

### **종료 코드 호환**

```cpp
enum class ExitCode {
    Success = 0,
    Error = 1,
    Warning = 2
};
```

---

## 🚀 **구현 로드맵**

### **Phase 1: MVP (2개월)**

```
Week 1-2: 프로젝트 설정
- CMake 구성
- 디렉토리 구조
- 기본 클래스 스켈레톤

Week 3-4: CLI + 파서
- CommandLine 구현
- 간단한 ISS 파서
- AST 구조

Week 5-6: 압축
- Compressor 인터페이스
- Zstd 구현
- SmartSelector 기본

Week 7-8: 빌더
- SetupBuilder 기본
- 스텁 로더
- 출력 생성
```

### **Phase 2: 완성 (3개월)**

```
Month 3: 전체 기능
- 모든 섹션 파싱
- 모든 압축 알고리즘
- 완전한 호환성

Month 4: 테스트
- 단위 테스트
- 통합 테스트
- 회귀 테스트

Month 5: 최적화
- 성능 튜닝
- 메모리 최적화
- 문서화
```

---

## 📋 **체크리스트**

### **필수 기능**

- [ ] ISS 파일 파싱
- [ ] [Setup] 섹션
- [ ] [Files] 섹션
- [ ] [Registry] 섹션
- [ ] Zstd 압축
- [ ] Brotli 압축
- [ ] Smart 선택
- [ ] Setup.exe 생성
- [ ] 스텁 로딩

### **호환성**

- [ ] 명령줄 옵션
- [ ] 출력 형식
- [ ] 종료 코드
- [ ] ISS 파일 형식
- [ ] Setup.exe 형식

### **품질**

- [ ] 단위 테스트 80%+
- [ ] 통합 테스트
- [ ] 문서화
- [ ] 에러 처리
- [ ] 성능 벤치마크

---

**문서 버전**: 1.0  
**작성일**: 2026-01-01 20:52 KST  
**상태**: 설계 완료, 구현 대기
