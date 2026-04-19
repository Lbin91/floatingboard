# FloatingBoard LLM Integration Contract

## 1. Purpose

이 문서는 FloatingBoard에서 LLM을 어떻게 붙일지에 대한 **구현 계약 문서**입니다.  
핵심 원칙은 단순합니다.

- LLM은 제품의 중심이 아니라 **구조화된 프롬프트 빌더의 보조 엔진**이다
- 사용자의 선택과 초안, 참고 문서를 기반으로 **정리(refine)** 또는 **번역(translate)** 을 수행한다
- LLM 호출 전후의 상태, 컨텍스트, 캐시, 문서 변경, 모델 변경 규칙을 명확히 정의한다

이 문서는 다음 질문에 답해야 합니다.

- 어떤 데이터를 LLM에 보내는가
- 어떤 상태를 세션으로 유지하는가
- 참고 문서가 바뀌면 무엇을 무효화하는가
- 모델을 바꾸면 무엇을 유지하고 무엇을 다시 생성해야 하는가
- 언제 호출을 취소하고, 언제 stale로 간주하는가

---

## 2. Role of LLM

FloatingBoard에서 LLM은 세 가지 역할만 맡습니다.

1. `refine`
   - 구조화된 선택값과 사용자 초안을 더 자연스러운 고품질 프롬프트로 정리
2. `translate`
   - 최종 프롬프트를 영어로 번역
3. `optional explain`
   - 후속 버전에서만 고려. MVP에서는 제외 가능

LLM이 맡지 않는 역할:

- 대주제/소주제/키워드 taxonomy 결정
- 키워드 슬롯 분류
- 참고 문서 선택 판단
- 프롬프트 기본 골격 생성 규칙 결정

즉, **구조는 로컬 엔진이 만들고, 문장 다듬기는 LLM이 맡는다**.

---

## 3. Integration Principles

### 3.1 Local First

LLM이 없어도 아래는 항상 가능해야 합니다.

- 대주제 선택
- 소주제 선택
- 키워드 수집
- 기본 프롬프트 조립
- 프롬프트 직접 수정
- 클립보드 복사

LLM 실패는 제품 전체 실패가 아니라, **보조 기능 실패**여야 합니다.

### 3.2 Structured Context, Not Chat Memory

FloatingBoard는 일반 채팅앱이 아닙니다.  
기본 컨텍스트는 대화 히스토리가 아니라 **구조화된 빌더 상태(snapshot)** 입니다.

기본 입력 원천:

- 현재 대주제
- 현재 소주제
- 선택된 키워드
- 현재 사용자 초안
- 현재 조립된 base prompt
- 현재 첨부된 참고 문서 snapshot
- 현재 task kind (`refine` 또는 `translate`)

### 3.3 No Silent Intelligence

LLM은 선택되지 않은 요구를 과하게 보강하면 안 됩니다.

- 새 제약을 임의로 추가 금지
- 새 기능 범위 제안 금지
- 문서에 없는 사실 단정 금지
- refine는 "명확화"이지 "확장 기획"이 아님

---

## 4. Core Concepts

### 4.1 Base Prompt

로컬 조립 엔진이 만든, 아직 LLM을 거치지 않은 프롬프트 초안입니다.

특징:
- deterministic
- 같은 입력이면 같은 결과
- 항상 재생성 가능
- LLM 결과의 기준점(source of truth)

### 4.2 Derived Output

LLM이 생성한 파생 결과입니다.

종류:
- refined prompt
- translated prompt

Derived output은 항상 base prompt에 종속됩니다.

### 4.3 Session

하나의 prompt builder 작업 단위입니다.

세션은 아래 상태를 가집니다.

- 현재 builder snapshot
- 마지막 base prompt
- 마지막 refined output
- 마지막 translated output
- 현재 사용 중 model config
- 현재 reference snapshot
- 현재 request fingerprint

### 4.4 Reference Snapshot

LLM 호출 시점의 참고 문서 상태를 고정한 스냅샷입니다.

포함값:
- 문서 id
- 경로
- scope (`global`, `project`, `external`)
- content hash
- modifiedAt
- 실제 전송된 텍스트
- truncation 여부

이 스냅샷이 중요한 이유는, 파일이 나중에 바뀌더라도 "그때 어떤 문서 기준으로 생성됐는지"를 추적할 수 있어야 하기 때문입니다.

---

## 5. State Model

### 5.1 Session State

```swift
struct LLMIntegrationSession {
    let draftID: UUID
    var taskState: LLMTaskState
    var builderSnapshot: BuilderSnapshot
    var basePrompt: GeneratedPrompt
    var refinedPrompt: GeneratedPrompt?
    var translatedPrompt: GeneratedPrompt?
    var referenceSnapshot: [ReferenceSnapshot]
    var activeModelConfig: LLMModelConfig?
    var lastRequestFingerprint: String?
}
```

### 5.2 Task State

```swift
enum LLMTaskState {
    case idle
    case refining
    case translating
    case completed
    case failed(LLMError)
    case cancelled
    case stale
}
```

### 5.3 Builder Snapshot

```swift
struct BuilderSnapshot {
    let topicID: String
    let subtopicID: String?
    let selectedKeywordIDs: [String]
    let userDraft: String
    let selectedReferenceDocumentIDs: [UUID]
    let editedPromptText: String?
}
```

`editedPromptText`는 사용자가 base prompt 또는 refined output을 직접 수정한 경우에만 채워집니다.

---

## 6. Request Lifecycle

### 6.1 Refine Request

순서:

1. 현재 builder snapshot을 읽는다
2. base prompt를 로컬에서 재조립한다
3. 선택된 참고 문서를 읽고 reference snapshot을 만든다
4. active model config를 읽는다
5. request fingerprint를 계산한다
6. 동일 fingerprint의 유효 결과가 있으면 재사용 여부를 판단한다
7. 없으면 LLM refine 요청을 보낸다
8. 결과를 `refinedPrompt`에 저장한다

### 6.2 Translate Request

순서:

1. 번역 대상 텍스트를 결정한다
2. 일반적으로 우선순위는 `edited text > refined prompt > base prompt`
3. active model config를 읽는다
4. request fingerprint를 계산한다
5. 번역 요청을 보낸다
6. 결과를 `translatedPrompt`에 저장한다

### 6.3 Cancellation Rules

아래 경우에는 진행 중 요청을 취소합니다.

- 사용자가 다시 `다듬기`를 눌렀을 때
- 사용자가 `번역`을 다시 눌렀을 때
- 대주제/소주제/키워드/초안을 바꿔 현재 요청이 stale이 되었을 때
- 모델 또는 참고 문서를 바꿔 현재 요청이 무의미해졌을 때
- 패널을 닫고 세션을 종료할 때

원칙:
- 세션당 동시에 하나의 active request만 허용
- `refine` 중 `translate`를 누르면 먼저 refine 취소 후 새 요청 또는 버튼 비활성화 중 택일
- MVP에서는 단순화를 위해 **직렬 실행**이 안전

---

## 7. Context Retention Rules

### 7.1 What Must Persist

세션 중 유지할 값:

- 마지막 builder snapshot
- 마지막 base prompt
- 마지막 refined prompt
- 마지막 translated prompt
- 마지막 model config
- 마지막 reference snapshot

### 7.2 What Must Not Persist Blindly

다음은 자동으로 다음 세션에 carry-over 하면 안 됩니다.

- 이전 세션의 refined prompt
- 이전 세션의 translated prompt
- 이전 세션의 reference snapshot
- 이전 세션의 request fingerprint

이전 세션 정보를 다시 쓰려면 명시적 "최근 작업 다시 열기" 흐름이 필요합니다.

### 7.3 Editable Output and Context

사용자가 refine 결과를 직접 수정한 경우:

- 해당 텍스트는 새로운 로컬 편집 결과로 간주
- 이후 번역은 이 수정본을 우선 입력으로 사용
- 이후 refine는 선택지 필요

권장 UX:
- `현재 편집본 기준으로 다시 다듬기`
- `기본 조립 프롬프트 기준으로 다시 다듬기`

MVP에서는 둘 중 하나만 먼저 지원해도 되지만, 내부 모델은 둘 다 구분 가능해야 합니다.

---

## 8. Reference Documents

### 8.1 Supported Scopes

```swift
enum ReferenceDocumentScope {
    case global
    case project
    case external
}
```

### 8.2 Load Policy

참고 문서는 LLM 호출 직전에 읽습니다.

읽기 규칙:
- 현재 활성 문서만 읽는다
- 존재하지 않는 파일은 제외하고 경고 상태를 남긴다
- 텍스트 크기가 너무 크면 truncation 정책 적용
- truncation 여부는 snapshot에 남긴다

### 8.3 Prompt Injection Position

참고 문서는 base prompt의 `References` 섹션 또는 LLM system/user payload 내 reference block으로 전달합니다.

권장 구조:

1. reference metadata
2. reference body
3. reference usage rule

예시:

```text
Reference: repo-rules.md
Scope: project
Usage rule: Use only as supporting context. Do not invent rules not present here.
Content:
...
```

### 8.4 Reference Change Handling

참고 문서가 바뀌면 기존 LLM 결과는 자동으로 신뢰할 수 없습니다.

처리 규칙:

- content hash가 바뀌면 `refinedPrompt`와 `translatedPrompt`를 `stale`로 표시
- base prompt는 문서가 직접 삽입되는 구조라면 재조립
- 이미 생성된 출력은 즉시 지우지 않고, "references changed" 배지 표시
- 사용자가 명시적으로 regenerate 하도록 유도

### 8.5 Missing / Invalid References

상황별 처리:

- 파일 삭제됨: 해당 문서 제외 + warning
- bookmark 복원 실패: external 문서 비활성화 + 재선택 요구
- 읽기 권한 없음: 해당 문서 제외 + error 상태 기록

원칙:
- 참고 문서 하나가 깨져도 전체 세션은 죽지 않아야 함

---

## 9. Model Configuration

### 9.1 Model Config Shape

```swift
struct LLMModelConfig: Equatable, Codable {
    let provider: AIProvider
    let modelID: String
    let temperature: Double
    let maxTokens: Int
    let language: String?
}
```

### 9.2 Model Change Rules

모델이 바뀌면 아래를 구분해서 처리합니다.

유지되는 것:
- builder snapshot
- base prompt
- reference snapshot metadata
- 사용자 직접 편집 텍스트

stale 처리되는 것:
- refined prompt
- translated prompt
- last request fingerprint

이유:
- base prompt는 로컬 조립 결과라 모델 비의존적
- refined/translated 결과는 모델 의존적

### 9.3 Config Change Granularity

아래 값 변경은 모두 "모델 변경"과 같은 효과를 냅니다.

- provider 변경
- modelID 변경
- temperature 변경
- maxTokens 변경
- 번역 언어 변경

즉, fingerprint 계산에 모두 포함해야 합니다.

---

## 10. Request Fingerprint and Cache

### 10.1 Fingerprint

동일 요청 여부 판단을 위해 fingerprint를 계산합니다.

입력값:
- task kind (`refine` / `translate`)
- base prompt text 또는 translation source text
- builder snapshot summary
- active model config
- reference snapshot hashes
- edited prompt source kind

예시:

```swift
fingerprint = hash(
    taskKind,
    sourceText,
    modelConfig,
    referenceHashes,
    builderSnapshot.selectedKeywordIDs,
    builderSnapshot.subtopicID
)
```

### 10.2 Cache Policy

MVP 권장:
- 세션 메모리 캐시만 사용
- 앱 재실행 후 복원은 optional
- 다른 모델 결과를 교차 재사용하지 않음

캐시 재사용 가능 조건:
- fingerprint 완전 동일
- reference snapshot 동일
- source text 동일

---

## 11. Prompt Contracts

### 11.1 Refine Prompt Contract

Refine용 system rule에 반드시 포함할 것:

- You are refining an already-structured prompt.
- Preserve the user intent and selected constraints.
- Do not invent new requirements.
- Keep the output concise but actionable.
- Respect attached references only as provided.

Refine 결과가 해야 하는 일:
- 어색한 반복 제거
- 요구사항 명료화
- 구조 정돈
- 영어가 아닌 원문 언어는 유지

Refine 결과가 하면 안 되는 일:
- 범위 확장
- 새 기술 스택 제안
- 테스트/보안/성능 요구 임의 추가

### 11.2 Translate Prompt Contract

Translate용 system rule에 반드시 포함할 것:

- Translate faithfully.
- Preserve structure and constraints.
- Do not summarize.
- Keep code, identifiers, and file names intact.

번역 결과는 아래를 유지해야 합니다.

- section structure
- bullet shape
- code block
- file path / symbol 명칭

---

## 12. Failure Handling

### 12.1 Failure Types

- API key missing
- provider unreachable
- timeout
- malformed response
- rate limit
- cancelled

### 12.2 UX Rules

- refine 실패 시 base prompt는 그대로 유지
- translate 실패 시 원문은 그대로 유지
- 에러는 destructive modal보다 inline error + retry가 적합
- stale 상태는 error가 아니라 재생성 필요 상태

### 12.3 Retry Rules

MVP 권장:
- 자동 재시도 없음 또는 1회 이하
- 사용자 명시 retry 우선
- rate limit은 짧은 안내 후 수동 재시도

---

## 13. Recommended UX States

### 13.1 Refine Button

상태:
- enabled
- loading
- disabled(no provider)
- stale-result-available

### 13.2 Translate Button

상태:
- enabled
- loading
- disabled(no provider)
- disabled(no source text)
- stale-result-available

### 13.3 Preview Badges

추천 badge:
- `BASE`
- `REFINED`
- `TRANSLATED`
- `STALE`
- `MISSING REFERENCES`

---

## 14. Testing Checklist

### 14.1 Context

- builder snapshot 변경 시 base prompt가 즉시 재조립되는가
- 사용자 편집본과 base prompt가 구분 저장되는가

### 14.2 References

- 문서 hash 변경 시 derived output이 stale 처리되는가
- 파일 삭제/권한 실패가 세션 전체 실패로 번지지 않는가

### 14.3 Models

- modelID 변경 시 refined/translated 결과만 stale 되는가
- base prompt와 사용자 편집본은 유지되는가

### 14.4 Requests

- 중복 refine 요청이 병렬로 쌓이지 않는가
- 취소 후 오래된 응답이 뒤늦게 UI를 덮어쓰지 않는가

---

## 15. MVP Decision Summary

현 시점의 구현 결정:

- LLM은 chat history 기반이 아니라 structured snapshot 기반으로 호출
- 세션당 active request는 하나만 허용
- reference file 변경은 derived output만 stale 처리
- model 변경은 derived output만 stale 처리
- base prompt는 항상 로컬 조립 결과를 source of truth로 유지
- 캐시는 세션 단위 fingerprint 기반으로 제한

이 문서의 목적은 LLM을 크게 설계하자는 것이 아니라,  
**작게 시작하되 나중에 꼬이지 않도록 지금 필요한 계약을 먼저 고정하는 것**입니다.
