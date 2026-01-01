# 현실적 C++ 포팅 전략 - 컴파일러만!

**작성일**: 2026-01-01 20:42  
**핵심 아이디어**: ISCC.exe만 C++로 포팅  
**평가**: ✅ **매우 현실적!**

---

## 💡 **핵심 통찰**

### **Inno Setup 구조**

```
Inno Setup = 3개 독립 프로그램

1. ISCC.exe (컴파일러)     ← 이것만 포팅!
   - ISS 스크립트 파싱
   - 파일 압축
   - 설치 파일 생성
   - UI 없음 (콘솔)

2. Compil32.exe (IDE)      ← 나중에 또는 안 해도 됨
   - 편집기
   - 디버거
   - VCL UI

3. Setup.exe (설치 프로그램) ← 나중에
   - 런타임
   - VCL UI
```

**핵심**: ISCC.exe는 **UI가 없음**! 콘솔 프로그램!

---

## 📊 **컴파일러 부분 분석**

### **파일 목록 (13개)**

```
Compiler.BuiltinPreproc.pas      - 전처리기
Compiler.Compile.pas             - 메인 컴파일 로직
Compiler.CompressionDLLs.pas     - DLL 로딩 (우리가 작성!)
Compiler.CompressionFactory.pas  - 팩토리 (우리가 작성!)
Compiler.CompressionHandler.pas  - 압축 처리
Compiler.ExeUpdateFunc.pas       - EXE 업데이트
Compiler.HelperFunc.pas          - 유틸리티
Compiler.Messages.pas            - 메시지/에러
Compiler.ScriptClasses.pas       - 스크립트 클래스
Compiler.ScriptCompiler.pas      - 스크립트 컴파일러
Compiler.ScriptFunc.pas          - 스크립트 함수
Compiler.SetupCompiler.pas       - Setup 컴파일러
Compiler.StringLists.pas         - 문자열 리스트
```

### **의존성**

```
Compiler.* (13개)
  ↓
Compression.* (10개) - 압축 시스템
  ↓
Shared.* (20개) - 공통 유틸리티
  ↓
Windows API
```

**총 약 40-50개 파일** (UI 없음!)

---

## 🎯 **포팅 난이도 재평가**

### **컴파일러만 포팅 시**

| 항목 | 전체 포팅 | 컴파일러만 | 개선 |
|------|----------|-----------|-----|
| **파일 수** | 132개 | ~50개 | **62% 감소** |
| **UI 의존성** | 40개 | 0개 | **100% 제거** |
| **VCL 의존성** | 많음 | 없음 | **완전 제거** |
| **예상 시간** | 2년 | **3-6개월** | **75% 감소** |
| **난이도** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | **훨씬 쉬움** |

---

## 💡 **왜 훨씬 쉬운가?**

### **1. UI 없음**

```cpp
// ISCC.exe는 콘솔 프로그램
int main(int argc, char* argv[]) {
    // ISS 파일 읽기
    // 파싱
    // 압축
    // 출력 파일 생성
    return 0;
}
```

**장점**:
- ✅ VCL 불필요
- ✅ Qt/wxWidgets 불필요
- ✅ 순수 로직만
- ✅ 표준 C++로 충분

---

### **2. 명확한 입출력**

```
입력: .iss 스크립트 파일
처리: 파싱 → 압축 → 패키징
출력: Setup.exe
```

**장점**:
- ✅ 명확한 스펙
- ✅ 테스트 용이
- ✅ 디버깅 쉬움

---

### **3. 기존 라이브러리 활용**

```cpp
// C++ 표준 라이브러리로 충분
#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <filesystem>

// 압축은 기존 라이브러리
#include <zstd.h>
#include <brotli/encode.h>
```

---

## 📋 **구체적 포팅 계획**

### **Phase 1: 코어 구조 (1개월)**

#### **파일 시스템**
```cpp
// Shared.FileClass.pas → FileSystem.cpp
class File {
public:
    void open(const std::string& path);
    void read(void* buffer, size_t size);
    void write(const void* buffer, size_t size);
    int64_t size() const;
};
```

#### **문자열 처리**
```cpp
// Shared.Struct.pas → Types.cpp
using String = std::string;
using AnsiString = std::string;

// 유틸리티
std::string ExtractFileName(const std::string& path);
std::string ChangeFileExt(const std::string& path, const std::string& ext);
```

---

### **Phase 2: 스크립트 파서 (2개월)**

#### **파서 구조**
```cpp
// Compiler.ScriptCompiler.pas → ScriptCompiler.cpp
class ScriptCompiler {
public:
    void parseScript(const std::string& filename);
    void compile();
    
private:
    void parseSetupSection();
    void parseFilesSection();
    void parseRegistrySection();
    // ...
};
```

#### **AST 구조**
```cpp
// Compiler.ScriptClasses.pas → AST.cpp
struct SetupEntry {
    std::string appName;
    std::string appVersion;
    CompressionMethod compression;
    // ...
};

struct FileEntry {
    std::string source;
    std::string dest;
    FileFlags flags;
};
```

---

### **Phase 3: 압축 시스템 (1개월)**

#### **이미 완성!**
```cpp
// 우리가 이미 Pascal로 작성한 것을 C++로
class CompressionFactory {
public:
    static std::unique_ptr<Compressor> 
    createCompressor(CompressionMethod method);
};

class SmartSelector {
public:
    static CompressionStrategy 
    selectStrategy(const std::string& filename);
};
```

---

### **Phase 4: 출력 생성 (1개월)**

#### **Setup.exe 생성**
```cpp
// Compiler.Compile.pas → Compiler.cpp
class SetupBuilder {
public:
    void buildSetup(const ScriptData& data);
    
private:
    void writeHeader();
    void compressFiles();
    void writeResources();
    void createExecutable();
};
```

---

## 🚀 **실제 구현 예시**

### **간단한 ISCC.exe 프로토타입**

```cpp
// main.cpp
#include <iostream>
#include <string>
#include "ScriptCompiler.h"
#include "SetupBuilder.h"

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: iscc <script.iss>\n";
        return 1;
    }
    
    try {
        // 스크립트 파싱
        ScriptCompiler compiler;
        compiler.parseScript(argv[1]);
        
        // Setup 빌드
        SetupBuilder builder;
        builder.buildSetup(compiler.getData());
        
        std::cout << "Compile successful!\n";
        return 0;
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << "\n";
        return 1;
    }
}
```

---

## 📊 **작업량 재평가**

### **현실적 타임라인**

| Phase | 작업 | 시간 |
|-------|-----|-----|
| **1** | 코어 구조 | 1개월 |
| **2** | 스크립트 파서 | 2개월 |
| **3** | 압축 시스템 | 1개월 |
| **4** | 출력 생성 | 1개월 |
| **5** | 테스트/디버깅 | 1개월 |
| **총계** | | **6개월** |

**1인 개발 기준**: 6개월  
**2-3인 팀**: 3-4개월

---

## 💡 **장점**

### **1. VS2022 Community 사용**

```
✅ 완전 무료
✅ 매출 $1M까지
✅ 250명까지
✅ 상업적 사용 가능
```

### **2. 현대적 C++**

```cpp
// C++20/23 기능 활용
auto files = std::views::filter(entries, 
    [](const auto& e) { return e.isFile(); });

// 파일시스템
namespace fs = std::filesystem;
for (const auto& entry : fs::directory_iterator(path)) {
    // ...
}
```

### **3. 크로스 플랫폼**

```
✅ Windows (MSVC)
✅ Linux (GCC/Clang)
✅ macOS (Clang)
```

---

## 🎯 **단계별 전략**

### **Step 1: MVP (2개월)**

```
목표: 기본 ISS 파일 컴파일

기능:
✅ [Setup] 섹션 파싱
✅ [Files] 섹션 파싱
✅ 파일 압축 (Zstd)
✅ Setup.exe 생성

제외:
⏸️ 고급 기능
⏸️ 레지스트리
⏸️ 스크립팅
```

### **Step 2: 기능 확장 (2개월)**

```
추가:
✅ 모든 섹션 지원
✅ Smart Compression
✅ 암호화
✅ 서명
```

### **Step 3: 완성 (2개월)**

```
완성:
✅ 전체 기능
✅ 에러 처리
✅ 최적화
✅ 문서화
```

---

## 📋 **필요한 라이브러리**

### **C++ 라이브러리**

```cpp
// 압축
#include <zstd.h>        // Zstandard
#include <brotli/encode.h> // Brotli
#include <lzma.h>        // LZMA

// 파일시스템
#include <filesystem>    // C++17

// JSON/설정 (선택)
#include <nlohmann/json.hpp>

// 암호화 (선택)
#include <openssl/sha.h>
```

**모두 오픈소스!**

---

## 🎊 **결론**

### **Q: ISS 파일 컴파일에 필요한 기능들만 구현하면?**

**A: 완전히 현실적입니다!**

```
전체 포팅: 2년, $200k
컴파일러만: 6개월, $50k

난이도: ⭐⭐⭐ (중간)
실현 가능성: ✅ 높음
```

### **핵심 장점**

```
✅ UI 없음 → VCL 불필요
✅ 콘솔 프로그램 → 간단
✅ 명확한 스펙 → 구현 용이
✅ VS2022 CE → 라이센스 자유
✅ 6개월 → 현실적
```

---

## 🚀 **즉시 시작 가능**

### **프로토타입 (1주일)**

```cpp
// 1. 간단한 파서
// 2. 파일 복사
// 3. Zstd 압축
// 4. EXE 생성

→ 기본 동작 검증
```

### **MVP (2개월)**

```cpp
// 1. 전체 파서
// 2. 모든 압축 알고리즘
// 3. 완전한 Setup.exe

→ 실제 사용 가능
```

---

## 💡 **최종 권장**

### **현실적 접근**

```
Phase 1: 우리 Pascal 코드 완성 (완료!)
Phase 2: Inno Setup에 기여
Phase 3: C++ 컴파일러 프로토타입 (6개월)
Phase 4: 커뮤니티 프로젝트로 확장
```

**이것이 가장 현실적입니다!**

---

**문서 버전**: 1.0  
**작성일**: 2026-01-01 20:45 KST  
**결론**: 컴파일러만 포팅 = 완전히 현실적!
