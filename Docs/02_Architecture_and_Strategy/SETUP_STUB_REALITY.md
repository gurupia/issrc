# 현실 체크 - Setup.exe 스텁 파일 문제

**작성일**: 2026-01-01 20:43  
**깨달음**: 컴파일러만으로는 부족하다!

---

## 💡 **중요한 발견**

### **Inno Setup 전체 구조**

```
ISCC.exe (컴파일러)
  ↓
ISS 스크립트 파싱
  ↓
파일 압축
  ↓
Setup.exe 생성
  ↓
Setup.exe = Setup 스텁 + 압축된 데이터
           ^^^^^^^^^^^^^^^^
           이것도 필요함!
```

---

## 📊 **Setup.exe 구성**

### **Setup 스텁 (런타임 엔진)**

```
Setup.* 파일: 39개
주요 기능:
- 설치 UI (VCL!)
- 파일 압축 해제
- 레지스트리 처리
- 파일 복사
- 스크립트 실행
- 언인스톨러
```

### **문제점**

```
Setup.MainForm.pas           - VCL UI
Setup.WizardForm.pas         - VCL UI
Setup.SelectLanguageForm.pas - VCL UI
Setup.SetupForm.pas          - VCL UI
...

→ VCL 의존성 다시 등장!
```

---

## 🎯 **전체 포팅 범위 재평가**

### **필요한 컴포넌트**

| 컴포넌트 | 파일 수 | UI | 난이도 |
|---------|--------|----|----|
| **ISCC.exe** | 13 | ❌ | ⭐⭐⭐ |
| **Setup.exe** | 39 | ✅ | ⭐⭐⭐⭐⭐ |
| **공통** | 20 | ❌ | ⭐⭐ |
| **압축** | 10 | ❌ | ⭐⭐ |
| **총계** | **82** | **혼합** | **⭐⭐⭐⭐** |

---

## 💡 **현실적 대안**

### **Option 1: 하이브리드 (가장 현실적)**

```
ISCC.exe: C++로 포팅
  - 콘솔 프로그램
  - UI 없음
  - 6개월

Setup.exe: Pascal 유지
  - 기존 스텁 사용
  - VCL UI 유지
  - 변경 불필요

→ 컴파일러만 C++, 스텁은 기존 것 사용
```

**방법**:
```cpp
// ISCC.exe (C++)
void buildSetup() {
    // 1. ISS 파싱
    // 2. 파일 압축
    // 3. 기존 Setup 스텁 로드
    loadStub("SetupStub.e32");  // Pascal로 빌드된 스텁
    // 4. 데이터 추가
    // 5. Setup.exe 생성
}
```

---

### **Option 2: 완전 포팅 (장기)**

```
ISCC.exe: C++ (6개월)
Setup.exe: C++ + Qt (12개월)

→ 총 18개월
→ VCL 완전 제거
→ 크로스 플랫폼
```

---

### **Option 3: 현재 유지 (즉시)**

```
모든 것: Pascal
  - 기존 코드 유지
  - 안정적
  - 검증됨

새 기능: C++ DLL
  - Smart Compression
  - 플러그인
```

---

## 🎯 **Setup 스텁 처리 방법**

### **방법 1: 기존 스텁 재사용**

```cpp
// C++ 컴파일러
class SetupBuilder {
public:
    void build() {
        // 1. 기존 Pascal 빌드 스텁 로드
        auto stub = loadPrebuiltStub("SetupStub.e32");
        
        // 2. 압축된 데이터 추가
        stub.appendData(compressedFiles);
        
        // 3. Setup.exe 저장
        stub.save("Output/Setup.exe");
    }
};
```

**장점**:
- ✅ Setup.exe 포팅 불필요
- ✅ 기존 UI 유지
- ✅ 빠른 구현

**단점**:
- ⏸️ Setup.exe는 여전히 Pascal
- ⏸️ 완전한 C++ 포팅 아님

---

### **방법 2: Setup.exe도 C++로**

```cpp
// C++ Setup (Qt)
class SetupWizard : public QWizard {
public:
    void run() {
        // 1. 언어 선택
        // 2. 라이센스
        // 3. 설치 경로
        // 4. 파일 압축 해제
        // 5. 완료
    }
};
```

**장점**:
- ✅ 완전한 C++ 포팅
- ✅ 크로스 플랫폼
- ✅ 현대적 UI

**단점**:
- ❌ 12개월+ 작업
- ❌ VCL → Qt 변환
- ❌ 모든 UI 재작성

---

## 📊 **작업량 최종 평가**

### **시나리오별 비교**

| 시나리오 | 컴파일러 | Setup | 총 시간 | 난이도 |
|---------|---------|-------|---------|--------|
| **현재 유지** | Pascal | Pascal | 0 | ⭐ |
| **하이브리드** | C++ | Pascal | 6개월 | ⭐⭐⭐ |
| **완전 포팅** | C++ | C++ | 18개월 | ⭐⭐⭐⭐⭐ |

---

## 💡 **최종 권장**

### **현실적 접근: 3단계**

#### **Phase 1: 현재 (즉시)**
```
✅ Pascal 코드 완성 (완료!)
✅ Smart Compression
✅ Inno Setup에 기여
```

#### **Phase 2: 하이브리드 (6개월)**
```
✅ ISCC.exe → C++
✅ Setup.exe → 기존 Pascal 스텁 사용
✅ VS2022 Community
```

#### **Phase 3: 완전 포팅 (2년)**
```
✅ ISCC.exe → C++
✅ Setup.exe → C++ + Qt
✅ 크로스 플랫폼
```

---

## 🎯 **Setup 스텁의 역할**

### **Setup.exe가 하는 일**

```
1. 사용자 인터페이스
   - 언어 선택
   - 라이센스 동의
   - 설치 경로 선택
   - 진행 상황 표시

2. 파일 처리
   - 압축 해제
   - 파일 복사
   - 레지스트리 수정

3. 스크립트 실행
   - [Code] 섹션 실행
   - 이벤트 핸들러

4. 언인스톨러 생성
   - unins000.exe
```

**모두 VCL UI 의존!**

---

## 🎊 **최종 결론**

### **Q: 스텁 파일도 있어야 하는구나?**

**A: 네, 그리고 이것도 VCL입니다.**

```
ISCC.exe: 콘솔 (포팅 쉬움)
Setup.exe: VCL UI (포팅 어려움)

→ 완전 포팅은 여전히 어려움
→ 하이브리드가 현실적
```

---

## 💡 **실용적 해결책**

### **우리 프로젝트**

```
✅ Pascal로 완성 (2,054줄)
✅ 프로덕션 품질
✅ 즉시 사용 가능

다음:
1. Inno Setup에 기여
2. 메인테이너 빌드
3. 공식 릴리스

C++ 포팅:
⏸️ 장기 프로젝트
⏸️ 커뮤니티 협력
⏸️ 점진적 접근
```

---

## 📋 **Setup 스텁 처리 옵션**

### **즉시 가능**

```
Option 1: 기존 스텁 사용
  - ISCC.exe만 C++
  - Setup.exe는 Pascal 빌드 재사용
  - 6개월

Option 2: 현재 유지
  - 모두 Pascal
  - 안정적
  - 즉시
```

### **장기 계획**

```
Option 3: 완전 포팅
  - ISCC.exe + Setup.exe 모두 C++
  - Qt UI
  - 18개월
```

---

**문서 버전**: 1.0  
**작성일**: 2026-01-01 20:45 KST  
**결론**: Setup 스텁도 필요. 하이브리드가 현실적!
