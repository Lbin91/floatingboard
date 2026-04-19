# llm-integration.md 검토 보고서

**날짜**: 2026-04-20
**검토 대상**: `docs/llm-integration.md` (commit `13b4485`)
**검토 기준**: Clarity / Testability / Specificity / Verification / Risk

---

## 평점: ★★★★☆ — REVISE (소규모 수정 권장)

이 문서는 **LLM을 제품의 보조 역할로 명확히 한정하는 계약서**로서 훌륭합니다. 핵심 원칙(Local First, No Silent Intelligence), 상태 모델, 무효화 규칙이 구체적이고 구현 가능하게 서술되어 있습니다. 다만 구현 착수 전 몇 가지 보강이 필요합니다.

---

## 1. 잘된 점

| 항목 | 평가 | 근거 |
|------|------|------|
| **역할 한정** | ★★★★★ | 섹션 2에서 LLM이 맡는 역할(refine, translate)과 맡지 않는 역할을 명확히 분리. "구조는 로컬 엔진이 만들고, 문장 다듬기는 LLM이 맡는다"가 한 줄로 요약됨 |
| **상태 모델** | ★★★★★ | 섹션 5의 Swift struct 정의(`LLMIntegrationSession`, `LLMTaskState`, `BuilderSnapshot`)가 바로 코드로 옮길 수 있을 정도로 구체적 |
| **무효화 규칙** | ★★★★★ | 섹션 8.4(참고 문서 변경), 섹션 9.2(모델 변경)의 stale 처리가 정확히 "무엇을 유지하고 무엇을 무효화하는지"를 명시. 모호함 없음 |
| **Request Lifecycle** | ★★★★☆ | 섹션 6의 refine/translate 요청 순서가 단계별로 서술됨 |
| **Prompt Contracts** | ★★★★☆ | 섹션 11의 system rule과 "하면 안 되는 일"이 실용적 |
| **No Silent Intelligence** | ★★★★★ | 섹션 3.3. LLM이 임의로 정보를 추가하는 것을 원천 차단. 이 원칙이 없으면 제품 정체성이 무너짐 |
| **테스트 체크리스트** | ★★★★☆ | 섹션 14에서 검증해야 할 항목이 구체적으로 나열됨 |

---

## 2. 수정 권장 사항

### 2.1 [중요] API 요청/응답 포맷 누락

**문제**: 이 문서는 "무엇을 LLM에 보내는가"를 상태 수준에서는 잘 정의하지만, **실제 HTTP 요청 스펙**이 누락되어 있습니다.

**필요한 내용**:
- OpenRouter/Ollama 요청 JSON 구조 예시 (refine용, translate용 각각)
- System prompt와 user prompt의 분리 방식
- 응답 파싱 규칙 (어떤 필드에서 결과를 추출하는지)
- 에러 응답 처리 (HTTP status code별 매핑)

**권장**: `docs/spec.md` 섹션 3.3에 "자세한 것은 llm-integration.md 참조"라고 되어 있으므로, 이 문서에서 최소한의 API 스펙을 정의해야 합니다. 예시:

```markdown
### 16.1 Refine 요청 예시 (OpenRouter)

POST https://openrouter.ai/api/v1/chat/completions
{
  "model": "openai/gpt-4o-mini",
  "messages": [
    {"role": "system", "content": "<refine_system_rule>"},
    {"role": "user", "content": "<base_prompt>"}
  ],
  "stream": false,
  "temperature": 0.3
}
```

### 2.2 [중요] Fingerprint 구현 상세 누락

**문제**: 섹션 10.1에서 fingerprint를 계산한다고 했지만, **실제 해시 알고리즘과 직렬화 방식**이 없습니다.

**필요한 내용**:
- 입력값의 직렬화 방식 (JSON → SHA-256? 문자열 결합 → hash?)
- `builderSnapshot.selectedKeywordIDs`의 정렬 순서 (순서가 다르면 다른 fingerprint가 됨)
- `sourceText`가 길면 fingerprint 계산 비용

**권장**: "SHA-256 of canonical JSON encoding" 정도로 한 줄 추가.

### 2.3 [보통] Refine vs Translate 직렬/병렬 실행 결정이 모호

**문제**: 섹션 6.3에서 "MVP에서는 단순화를 위해 직렬 실행이 안전"이라고 했지만, 구체적인 정책이 불명확합니다.

**질문**:
- `refine` 완료 후 `translate`를 누르면, translate의 소스는 refined result인가 base인가?
- 섹션 6.2에서는 "우선순위: edited text > refined prompt > base prompt"라고 했는데, 이것이 항상 적용되는가?
- "refine 중 translate를 누르면" — 버튼 비활성화인가, 큐잉인가?

**권장**: 섹션 6.3에 **MVP 동작 표**를 추가:

```markdown
| 시나리오 | MVP 동작 |
|---------|---------|
| refine 중 translate 클릭 | translate 버튼 비활성화 |
| translate 중 refine 클릭 | 진행 중 translate 취소 후 refine 시작 |
| refine 완료 후 translate | translate 소스 = refined result |
| 사용자 편집 후 translate | translate 소스 = edited text |
```

### 2.4 [보통] Truncation 정책이 선언만 있고 기준이 없음

**문제**: 섹션 8.2에서 "텍스트 크기가 너무 크면 truncation 정책 적용"이라고만 되어 있습니다.

**필요한 내용**:
- "너무 크다"의 기준 (예: 총 참고 문서 10,000자? 토큰 기준 4,000 token?)
- truncation 방식 (앞에서 자르기? 뒤에서? 요약?)
- truncation 시 사용자 피드백 ("일부 내용이 생략되었습니다")

**권장**: MVP 기준을 한 줄로 명시:

```markdown
MVP 기준: 참고 문서 총합 8,000자 초과 시 앞에서부터 순차 포함, 초과분 제외.
Truncation 발생 시 snapshot에 `truncated: true` 기록.
```

### 2.5 [낮음] LLMModelConfig에 provider endpoint 누락

**문제**: 섹션 9.1의 `LLMModelConfig`에 `provider`와 `modelID`는 있지만, **endpoint URL**이 없습니다.

- OpenRouter는 고정(`https://openrouter.ai/api/v1/chat/completions`)이지만
- Ollama는 사용자가 커스텀 endpoint를 설정 가능 (기본 `http://localhost:11434`)

**권장**:
```swift
struct LLMModelConfig: Equatable, Codable {
    let provider: AIProvider
    let modelID: String
    let endpoint: String?  // nil이면 provider 기본 endpoint
    let temperature: Double
    let maxTokens: Int
    let language: String?
}
```

### 2.6 [낮음] 세션 경계가 불명확

**문제**: 섹션 4.3에서 "하나의 prompt builder 작업 단위"라고 세션을 정의했지만, **세션의 시작과 끝**이 명시되지 않았습니다.

- 패널 열기 = 세션 시작?
- 패널 닫기 = 세션 종료?
- 앱 재시작 후 이전 세션 복원은?

**권장**: 한 줄 추가:
```markdown
세션은 패널이 열릴 때 시작되고, 패널이 닫힐 때 종료됩니다.
MVP에서는 세션 간 상태 복원을 지원하지 않습니다.
```

---

## 3. spec.md와의 일관성 검토

| 항목 | 일치 여부 | 비고 |
|------|-----------|------|
| LLM 역할 (보조) | ✅ | spec.md 섹션 5.4 "LLM 사용은 옵션"과 일치 |
| 비스트리밍 | ✅ | spec.md 섹션 3.3 "JSON POST 기반 비스트리밍 우선"과 일치 |
| 참고 문서 처리 | ✅ | spec.md 섹션 5.5 References와 일치 |
| 데이터 모델 | ✅ | spec.md 섹션 8의 `PromptDraft`, `ReferenceDocument`와 일치 |
| 상태 복원 | ✅ | spec.md 섹션 6.3 "이전 선택을 바꿔도 초안 텍스트는 보존"과 일치 |
| **spec.md 참조** | ✅ | spec.md 섹션 3.3에서 이 문서를 명시적으로 참조 중 |
| **Platform** | ⚠️ | llm-integration.md는 macOS 언급 없음. spec.md는 macOS 14.0+. 문서 자체는 platform-agnostic이라 문제는 아니지만, URLSession 등 macOS 전용 고려사항이 있을 수 있음 |

---

## 4. 종합 판정

| 기준 | 평가 | 비고 |
|------|------|------|
| **Clarity** | ★★★★☆ | 상태 모델과 무효화 규칙은 매우 명확. API 스펙과 fingerprint 상세는 보강 필요 |
| **Testability** | ★★★★☆ | 테스트 체크리스트가 구체적. truncation 기준과 직렬/병렬 정책만 명시되면 테스트 가능 |
| **Specificity** | ★★★★★ | Swift struct 수준의 구체성. 모호한 표현 거의 없음 |
| **Verification** | ★★★★☆ | 파일 참조 없음(독립 문서). spec.md와의 일관성은 확인 완료 |
| **Risk** | ★★★★☆ | 리스크 식별은 충분. truncation, 세션 경계 관련 엣지 케이스 보강 필요 |

**판정: REVISE** — 핵심 구조는 훌륭하나, 구현 착수 전 **API 스펙 보강(2.1)**, **직렬/병렬 정책 명시(2.3)**, **truncation 기준(2.4)** 세 가지를 추가하면 APPROVED.
