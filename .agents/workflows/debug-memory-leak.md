---
description: 디버깅, 메모리 누수 탐지 및 보안 강화를 위한 글로벌 통합 워크플로우
---

# 글로벌 통합 디버깅, 메모리 누수 파악 및 보안 워크플로우

이 워크플로우는 소프트웨어의 신뢰성, 성능, 그리고 보안을 보장하기 위한 가장 기본적이며 필수적인 절차입니다.
어떤 언어나 환경(C++, C#, Python, Delphi 등)에서도 적용될 수 있는 보편적인 접근 방식을 제공합니다.

## 🚀 워크플로우 실행 트리거 (When to use)
이 워크플로우는 다음 상황에서 반드시 검토 및 실행되어야 합니다:
- 주요 기능 추가 또는 아키텍처 리팩토링 후 PR (Pull Request) 승인 전 자가 진단
- 운영(Production) 환경에서 알 수 없는 크래시, 성능 저하 또는 OOM(Out of Memory) 이벤트 발생 시
- 서드파티 라이브러리 추가 및 대규모 프레임워크 업데이트 직후

---

## Phase 1: 디버깅 및 에러 추적 (재현과 로깅)

디버깅의 가장 첫 번째 단계는 "추측하지 않고 증명하는 것"입니다.

- **증상 스크랩:**
  문제가 발생하는 정확한 조건(OS, 컴파일러 버전, 사용자의 입력)을 기록합니다.
- **최소 재현 가능 예제 (MinRepro) 작성:**
  버그가 발생하는 가장 작고 독립적인 코드를 분리합니다.
- **로깅 활성화 및 분석:**
  에러를 조용히 삼키는 빈 `catch`나 `except` 블록이 있다면 즉시 구조적 로깅 코드로 대체합니다. 
  모든 외부 시스템 경계 지점 (네트워크, 파일 읽기/쓰기, DB 쿼리)에 시점과 파라미터 로그를 추가합니다.
- **Fail-Fast 검증:**
  함수 진입점 등에서 인자의 유효성을 검사하는 Guard Clause를 추가하여, 문제가 발생하기 전 최대한 빨리 실패하도록 유도합니다.

---

## Phase 2: 메모리 누수 및 리소스 관리

자원 관리의 원칙은 "할당한 자가 책임지고 해제한다"입니다.

- **할당-해제 매칭 검증:**
  가비지 컬렉터(GC) 환경이 아닌 코드(C/C++, Delphi 등)에서는 `new/delete`, `malloc/free`, `Create/Free` 쌍이 제대로 맺어졌는지 확인합니다. 열린 파일 핸들, DB 커넥션, 네트워크 소켓 등이 정상적으로 닫혔는지(`using`, `try-finally` 패턴 등) 검수합니다.
- **생명주기(Lifecycle) 점검:**
  이벤트 리스너, 델리게이트, 옵저버 패턴 사용 시 구독 해지가 명확하게 이루어지고 있는지 확인(Dangling Pointer 및 로직 누수 방지).
- **정적/동적 분석 도구 실행:**
  - **C/C++:** AddressSanitizer (ASan), Visual Studio Diagnostic Tools(Windows), Valgrind(Linux).
  - **.NET:** dotMemory, Visual Studio 프로파일러, CLI 기반 진단 도구(`dotnet-dump`, `dotnet-gcdump`, `dotnet-trace`).
  - **Delphi:** FastMM4 리크 리포팅 켜기(`ReportMemoryLeaksOnShutdown := True`), 실질적인 운영 환경 에러 트래픽 캡처를 위한 EurekaLog 또는 MadExcept 통합.

---

## Phase 3: 동시성 및 멀티스레딩 검증 (Concurrency & Thread Safety)

공유 자원으로 인한 문제는 간헐적으로 발생하므로 설계 단계부터 엄격히 검증해야 합니다.

- **공유 상태(Shared State) 최소화 및 불변성(Immutability):**
  다중 스레드 간 상태 공유를 피하거나 불변 객체로 유지합니다.
- **동기화 및 락(Lock) 확인:**
  교착 상태(Deadlock) 방지를 위해 락의 범위를 최소화하고, 순환 대기(Circular Wait)가 발생하지 않는지 검토합니다.
  (비동기 await 환경에서는 UI 스레드가 블로킹되지 않도록 주의합니다.)
- **분석 도구 적용:**
  ThreadSanitizer(TSan)나 Concurrency Visualizer 등을 사용하여 숨겨진 경쟁 상태(Race Condition)를 탐지합니다.

---

## Phase 4: 보안 및 안전성 강화 (Zero Trust)

설계의 경계를 넘어오는 모든 데이터와 의존성은 잠재적인 공격 벡터입니다.

- **입력 데이터 엄격 검증 (Input Validation):**
  외부에서 들어오는 모든 입력은 절대로 신뢰하지 않으며, 엄격한 화이트리스트 검사, 타입 체크 및 길이 제한을 수행합니다. String interpolation이나 단순 연결을 사용한 SQL 쿼리는 인젝션(SQL Injection) 위험이 있으므로 반드시 Prepared Statement(매개변수화된 쿼리) 방식 등으로 수정합니다.
- **메모리 안전성 확보:**
  C/C++ 또는 Rust의 Unsafe 블록 내부 포인터 연산을 제한하고스마트 포인터 연산(`std::unique_ptr`, `std::shared_ptr`) 및 RAII 패턴을 적용하여 버퍼 오버플로우나 잘못된 메모리 참조를 원천 차단합니다.
- **최소 권한의 원칙 (Least Privilege):**
  실행 환경, 앱, 그리고 마이크로서비스 간 통신에서 최소한의 권한과 스코프만 사용하도록 제한합니다(UAC 남용 방지 등).
- **비밀 정보 보호 (Secret Management):**
  소스 코드에 하드코딩된 API Key, 비밀번호 등을 폐기하고, 이를 모두 환경 변수나 안전한 보안 볼트(Vault, Azure Key Vault 등)에서 런타임에 주입받도록 정책을 수정합니다.
- **공급망 보안 및 의존성 검사 (SCA):**
  내가 짠 코드 외에도 외부 라이브러리에 취약점이 없는지 검사합니다(npm audit, NuGet 취약점 검증, Dependabot, CodeQL 등 활용).

---

## Phase 5: 리뷰 및 회고

- [ ] 버그 수정, 리팩토링, 보안 강화 로직 적용 후 기존 시스템에 부작용(Side Effect)을 일으키는지 유닛/통합 테스트 케이스를 통해 재차 실행 및 점검합니다.
- [ ] 적용된 수정 사항을 기술 문서로 기록하고, 팀 내 코드 리뷰를 통해 전파하며 가능하다면 CI/CD 자동화 파이프라인에 린팅 및 정적 분석 패스를 의무적으로 연동합니다.
