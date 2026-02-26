# ISIDE.exe Access Violation 오류 분석 보고서

**작성일**: 2026-01-22  
**상태**: 🟡 **이슈로 보류** - 근본 원인은 TNewTabSet 컴포넌트 로딩 문제

---

## 요약

- `MemosTabSet` (TNewTabSet 타입) 컴포넌트가 DFM에서 로드되지 않아 nil 상태
- 9개 위치에 nil 체크 추가했으나 더 많은 위치에서 접근 발생
- **근본적 해결**: TNewTabSet 컴포넌트 등록/로드 문제 해결 필요

---

```txt
Access violation at address 010B2519 in module 'ISIDE.exe'
(offset 2F2519). Read of address 00000008.
```

### 1.2 발생 시점

- **ISIDE.exe 시작 시** (런타임 오류)
- 빌드는 성공적으로 완료됨
- 폼 초기화 과정에서 발생

### 1.3 오류 특징

| 항목      | 값         | 의미                         |
| --------- | ---------- | ---------------------------- |
| 오프셋    | 0x002F2519 | 일관된 코드 위치             |
| 읽기 주소 | 0x00000008 | nil 포인터 + 8바이트 오프셋  |
| 패턴      | nil 역참조 | 객체.필드 접근 시 객체가 nil |

---

## 2. 원인 분석

### 2.1 오프셋 0x00000008의 의미

```txt
오프셋 8 = nil 포인터에서 두 번째/세 번째 필드 접근
32비트 Delphi 객체 구조:
  +0: VMT 포인터
  +4: 첫 번째 필드
  +8: 두 번째 필드  ← 이 위치에서 오류
```

### 2.2 가능한 원인

#### A. DFM 컴포넌트 로딩 실패

| 컴포넌트                | 타입          | DFM 라인 | 상태      |
| ----------------------- | ------------- | -------- | --------- |
| MemosTabSet             | TNewTabSet    | 40       | ⚠️ 커스텀 |
| OutputTabSet            | TNewTabSet    | 134      | ⚠️ 커스텀 |
| CompressionComboBox     | TComboBox     | 348      | ✅ 표준   |
| UpdatePanelDonateBitBtn | TBitmapButton | 395      | ⚠️ 커스텀 |

#### B. 초기화 순서 문제

- `inherited Create` 후 컴포넌트 접근 시 일부가 nil일 수 있음

---

## 3. 시도한 해결 방법 (미해결)

### 3.1 Nil 체크 추가

- CompressionComboBox 초기화 (Line 1053)
- MemosTabSet.PopupMenu (Line 1088)
- UpdateBevel1Visibility (Line 6647)

### 3.2 결과

❌ **동일한 Access Violation 지속**

---

## 4. 수정된 파일 목록

| 파일                              | 수정 내용         |
| --------------------------------- | ----------------- |
| `IDE.MainForm.pas`                | nil 체크 추가     |
| `IDE.MainForm.dfm`                | 컴포넌트 추가     |
| `Compression.Brotli.pas`          | DLL 함수 nil 체크 |
| `Compression.Zstd.pas`            | DLL 함수 nil 체크 |
| `Compiler.CompressionHandler.pas` | inline var 제거   |
| `Shared.CompilerInt.pas`          | inline var 제거   |

---

## 5. 권장 해결 방법

### 5.1 디버그 모드 실행 (필수)

1. Delphi IDE에서 `Projects\ISIDE.dproj` 열기
2. **F9** 실행 (디버그 모드)
3. Access Violation 시 **"Break"** 클릭
4. **View → Debug Windows → Call Stack** 확인
5. 정확한 라인 번호 확인

### 5.2 대안

- Smart Compression IDE 변경사항 임시 롤백
- 원본 소스에서 단계별 적용 테스트

---

## 6. 결론

| 항목                   | 상태                |
| ---------------------- | ------------------- |
| Smart Compression 기능 | ✅ 정상 작동        |
| ISIDE.exe 시작         | ❌ Access Violation |
| 해결에 필요한 정보     | Call Stack          |

**다음 단계**: Delphi 디버거로 정확한 오류 위치 확인
