# Phase 3 구현 계획서: LLM 다듬기 / 영어 번역

## 1. 목표

구조화 빌더에서 생성된 base prompt를 LLM으로 다듬고(refine), 영어로 번역(translate)하는 기능을 추가한다. LLM은 제품의 중심이 아니라 보조 엔진이며, API Key 없이도 앱의 기본 가치는 그대로 동작해야 한다.

## 2. 범위

### 포함
- AI 설정 UI (Provider/Model/API Key 구성)
- `RefinePromptUseCase` — base prompt → 다듬어진 프롬프트
- `TranslatePromptUseCase` — 다듬기/편집 결과 → 영어 번역
- LLM 세션 상태 관리 (fingerprint, stale, cancellation)
- 에러 처리 UX (inline error, retry)
- Keychain 기반 API Key 저장
- `saveDraft()` panel close 시 자동 트리거

### 제외
- 참고 문서 연결 (Phase 4)
- 다른 언어 번역 (영어만 MVP)
- 스트리밍 응답
- 세션 간 LLM 결과 복원
- 채팅 히스토리 기반 대화

## 3. 작업 항목

### §19. Keychain 기반 API Key 관리

**목표**: API Key를 안전하게 저장하고 불러온다.

- [ ] `KeychainRepository` 프로토콜 정의 (`Domain/Repositories/KeychainRepository.swift`)
  - `func save(key: String, data: Data) throws`
  - `func load(key: String) throws -> Data?`
  - `func delete(key: String) throws`
- [ ] `KeychainRepositoryImpl` 구현 (`Data/Repositories/KeychainRepositoryImpl.swift`)
  - `Security` framework `SecItemAdd` / `SecItemCopyMatching` / `SecItemDelete`
  - `kSecClassGenericPassword`, `kSecAttrService: "com.floatingboard"`
  - `kSecAttrAccount`로 provider 구분 (`openrouter-api-key`, `ollama-endpoint`)
- [ ] 단위 테스트: save → load → delete 라운드트립

**완료 기준**: API Key를 Keychain에 저장/조회/삭제 가능, 평문 파일에 키 없음

### §20. LLMModelConfig 및 AIProvider 모델 확장

**목표**: LLM 호출에 필요한 설정 모델을 정의한다.

- [ ] `AIProvider` enum 확장 (`Domain/Entities/AIProvider.swift`)
  - 현재: `case openRouter, ollama` (정의만 있음)
  - 추가: 각 provider의 기본 endpoint, 기본 model, 인증 방식 정의
- [ ] `LLMModelConfig` struct 정의 (`Domain/Entities/LLMModelConfig.swift`)
  ```swift
  struct LLMModelConfig: Equatable, Codable {
      let provider: AIProvider
      var modelID: String
      var endpoint: String?
      var temperature: Double
      var maxTokens: Int
  }
  ```
- [ ] `LLMError` enum 정의 (`Domain/Entities/LLMError.swift`)
  - `apiKeyMissing`, `authenticationFailed`, `timeout`, `rateLimited`
  - `providerUnavailable`, `malformedResponse`, `cancelled`
  - `LocalizedError` 채택 (한국어 errorDescription)

**완료 기준**: 모델 설정과 에러 타입이 코드에 존재, Codable로 직렬화 가능

### §21. AIRepository 프로토콜 + Provider 구현체

**목표**: LLM API 호출 추상화 레이어를 만든다.

- [ ] `AIRepository` 프로토콜 정의 (`Domain/Repositories/AIRepository.swift`)
  ```swift
  protocol AIRepository {
      func refine(prompt: String, config: LLMModelConfig) async throws -> String
      func translate(text: String, config: LLMModelConfig) async throws -> String
  }
  ```
- [ ] `OpenRouterRepository` 구현 (`Data/Repositories/OpenRouterRepository.swift`)
  - `URLSession` async/await 기반
  - endpoint: `https://openrouter.ai/api/v1/chat/completions`
  - 인증: `Authorization: Bearer <api_key>`
  - 요청/응답 DTO: `LLMRefineRequest`, `LLMRefineResponse` (`Data/DTOs/`)
  - timeout: 연결 10초, 응답 60초
  - `stream: false` (비스트리밍)
- [ ] `OllamaRepository` 구현 (`Data/Repositories/OllamaRepository.swift`)
  - endpoint: 사용자 설정 (기본 `http://localhost:11434/api/chat`)
  - 인증: 없음 (로컬)
  - 동일 DTO 구조, Ollama 응답 파싱 (`message.content`)
- [ ] `AIRepositoryProvider` 구현 (`Data/Repositories/AIRepositoryProvider.swift`)
  - 현재 설정된 `AIProvider`에 따라 적절한 `AIRepository` 구현체를 반환하는 래퍼
  - `@MainActor` 클래스, 내부에 `OpenRouterRepository`, `OllamaRepository` 인스턴스를 모두 보유
  - 설정 변경 시에도 인스턴스 교체 없이 라우팅만 전환 → `DependencyContainer`는 `AIRepositoryProvider`만 주입
  - `func resolve(for provider: AIProvider) -> AIRepository`
- [ ] 공통 에러 매핑: HTTP 상태코드 → `LLMError`
- [ ] `RefinePromptUseCase` 구현 (`Domain/UseCases/RefinePromptUseCase.swift`)
  - system prompt: "You are refining an already-structured prompt..." (llm-integration.md §11.1)
  - 입력: base prompt text + LLMModelConfig
  - 출력: refined prompt text
- [ ] `TranslatePromptUseCase` 구현 (`Domain/UseCases/TranslatePromptUseCase.swift`)
  - system prompt: "Translate faithfully. Preserve structure..." (llm-integration.md §11.2)
  - 번역 대상 결정 우선순위: `edited text > refined prompt > base prompt`
- [ ] 단위 테스트: DTO 인코딩/디코딩, 에러 매핑

**완료 기준**: 두 provider 모두 프로토콜 준수, 설정 변경 시 런타임에 Provider 스위칭 가능

### §22. LLM 세션 상태 관리

**목표**: 세션 내 LLM 결과의 라이프사이클을 관리한다.

- [ ] `LLMTaskState` enum 정의 (`Domain/Entities/LLMTaskState.swift`)
  ```swift
  enum LLMTaskState: Equatable {
      case idle
      case refining
      case translating
      case completed
      case failed(LLMError)
      case cancelled
      case stale
  }
  ```
- [ ] `PromptBuilderViewModel`에 LLM 상태 추가
  - `llmTaskState: LLMTaskState`
  - `refinedPrompt: String?`
  - `translatedPrompt: String?`
  - `activeModelConfig: LLMModelConfig?`
- [ ] Request fingerprint 계산 로직
  - `SHA-256(canonical JSON)` 기반
  - 입력: task kind + source text + model config + keyword IDs (정렬됨)
  - 동일 fingerprint → 세션 내 캐시 재사용
- [ ] Stale 전파 규칙 구현
  - 선택값 변경 → refined/translated stale
  - 모델 설정 변경 → refined/translated stale
  - stale 시 기존 결과 유지 + "stale" 배지
- [ ] Cancellation 규칙
  - 세션당 1개 active request
  - 새 요청 시 기존 요청 취소 (`Task.cancel()`)
  - 패널 닫기 시 in-flight 요청 취소
- [ ] `PromptPreviewMode` 확장: `.generated`, `.edited`, `.refined`, `.translated`

**완료 기준**: LLM 결과가 stale/cancel 규칙에 따라 일관되게 관리됨

### §23. AI 설정 UI

**목표**: 사용자가 Provider, Model, API Key를 구성할 수 있게 한다.

- [ ] `AISettingsView` 구현 (`Presentation/Preferences/AISettingsView.swift`)
  - Provider 선택: OpenRouter / Ollama (Picker)
  - API Key 입력: SecureField + Keychain 저장 (OpenRouter만)
  - Ollama endpoint 입력: TextField (기본값 `http://localhost:11434`)
  - Model 선택: TextField (향후 모델 목록 API 연동 검토)
  - Temperature 슬라이더 (0.0 ~ 1.0)
  - Max Tokens 입력
  - "Test Connection" 버튼 → 실제 API 호출 후 성공/실패 표시
- [ ] `PreferencesView` 탭 구성
  - 현재: placeholder
  - 확장: General / AI / Documents / Hotkey 탭 구조
- [ ] 설정 저장: `@AppStorage` + Keychain 혼합
  - Provider, modelID, temperature, maxTokens → `@AppStorage`
  - API Key → Keychain
- [ ] 설정 변경 시 `activeModelConfig` 업데이트 → derived output stale 처리

**완료 기준**: 설정창에서 AI 구성 후 "Test Connection" 성공 시 응답 표시

### §24. Refine / Translate 액션 UI

**목표**: 빌더 패널에서 LLM 액션을 실행할 수 있게 한다.

- [ ] `ActionBarView`에 Refine / Translate 버튼 추가
  - Refine: `(LLMModelConfig 유효)` 시 활성화, 로딩 스피너, stale 배지
  - Translate: `(source text 존재) AND (LLMModelConfig 유효)` 시 활성화, 로딩 스피너
  - 두 버튼 동시 활성화 불가 (직렬 실행)
- [ ] `PromptPreviewView`에 Refine / Translated 모드 탭 추가
  - `.generated` | `.edited` | `.refined` | `.translated` 4개 모드
  - 각 모드에 맞는 배지: BASE, EDITED, REFINED, TRANSLATED, STALE
  - Stale 결과는 warning 색상으로 표시
- [ ] Inline error 표시
  - 실패 시 preview 하단에 error caption (destructive modal 아님)
  - retry는 해당 버튼 재활성화로 제공
- [ ] ViewModel에 `refinePrompt()`, `translatePrompt()` async 메서드 추가
  - `@MainActor` 격리 보장: ViewModel 전체가 이미 `@MainActor`이므로, `Task { }` 블록 내 상태 변경도 메인 스레드에서 수행됨. 비동기 네트워크 호출만 백그라운드에서 실행 후 결과를 메인 액터로 복귀
  - `Task { }`로 비동기 실행, `llmTaskState`를 `.refining` / `.translating`으로 설정
  - 네트워크 호출 결과를 메인 스레드에서 `refinedPrompt` / `translatedPrompt`에 반영
  - 에러 핸들링 분기:
    - `CancellationError` → `llmTaskState = .cancelled` (`.failed`로 래핑 금지)
    - `LLMError` → `llmTaskState = .failed(error)`, 기존 결과 유지
    - 정상 → `llmTaskState = .completed`

**완료 기준**: Refine 클릭 → 로딩 → 결과 표시 → Translate 클릭 → 영어 번역 결과 표시

### §25. Panel Close 자동 저장

**목표**: 패널 닫기 시 현재 상태를 자동 저장한다.

- [ ] `DependencyContainer.showPromptBuilder()`의 `onClose` 콜백 수정
  - 패널 닫기 이벤트 발생 시 반드시 아래 순서로 동기 실행:
    1. `viewModel`에 in-flight LLM Task가 있으면 `cancel()` 즉시 발행
    2. `viewModel.saveDraft()` 호출 (상태 영속화)
    3. `floatingPanelController.close()` 호출 (창 닫기)
  - `@MainActor` 보장하에 순차 실행
- [ ] 테스트: 패널 열기 → 상태 변경 → 패널 닫기 → 재실행 → 상태 복원

**완료 기준**: 패널 닫은 후 앱 재실행 시 직전 상태 복원

### §26. Phase 3 검증

- [ ] 전체 빌드 성공
- [ ] 기존 테스트 통과
- [ ] 신규 테스트 추가
  - Refine useCase 단위 테스트 (mock repository)
  - Translate useCase 단위 테스트
  - Stale 전파 테스트 (선택값 변경 → refined stale)
  - Fingerprint 캐시 재사용 테스트
  - Keychain roundtrip 테스트
  - ViewModel refine/translate 상태 전이 테스트
- [ ] 수동 검증
  - API Key 없이 앱 정상 동작 (기본 기능)
  - OpenRouter 설정 후 Refine 성공
  - Ollama 설정 후 Refine 성공
  - Refine → Translate 플로우
  - 네트워크 오류 시 inline error 표시
  - 설정 변경 후 stale 배지 표시

**완료 기준**: LLM 없이도 기본 기능 동작, LLM 설정 시 refine/translate 플로우 완주

## 4. 구현 순서

```
§19 Keychain ──────────────────────────┐
§20 LLMModelConfig + LLMError ─────────┤ (병렬)
                                        ↓
§21 AIRepository + UseCases ────────────┤
§23 AI 설정 UI ─────────────────────────┤ (§21 이후)
                                        ↓
§22 LLM 세션 상태 관리 ─────────────────┤
§24 Refine/Translate 액션 UI ──────────┤ (§22 이후)
                                        ↓
§25 Panel Close 자동 저장 ──────────────┤ (독립)
§26 검증 ──────────────────────────────┘
```

**병렬 가능 구간**:
- §19 + §20 동시 진행 (서로 독립)
- §21 완료 후 §23 진행
- §22 완료 후 §24 진행
- §25은 §22 독립, 언제든 가능

## 5. 새로운 파일 구조

```
FloatingBoard/
├── Domain/
│   ├── Entities/
│   │   ├── AIProvider.swift              # 기존, 확장
│   │   ├── LLMModelConfig.swift          # 신규
│   │   ├── LLMError.swift                # 신규
│   │   └── LLMTaskState.swift            # 신규
│   ├── UseCases/
│   │   ├── BuildPromptUseCase.swift      # 기존
│   │   ├── RefinePromptUseCase.swift     # 신규
│   │   └── TranslatePromptUseCase.swift  # 신규
│   └── Repositories/
│       ├── TaxonomyRepository.swift      # 기존
│       ├── PromptDraftRepository.swift   # 기존
│       ├── AIRepository.swift            # 신규
│       └── KeychainRepository.swift      # 신규
├── Data/
│   ├── Repositories/
│   │   ├── LocalTaxonomyRepository.swift       # 기존
│   │   ├── LocalPromptDraftRepository.swift    # 기존
│   │   ├── OpenRouterRepository.swift          # 신규
│   │   ├── OllamaRepository.swift              # 신규
│   │   ├── AIRepositoryProvider.swift          # 신규 (Provider 래퍼)
│   │   └── KeychainRepositoryImpl.swift        # 신규
│   └── DTOs/
│       ├── TaxonomyDTO.swift             # 기존
│       ├── LLMRequest.swift              # 신규
│       └── LLMResponse.swift             # 신규
├── Presentation/
│   ├── PromptBuilder/
│   │   ├── PromptBuilderViewModel.swift  # 수정: LLM 상태 추가
│   │   ├── PromptPreviewView.swift       # 수정: 4모드 확장
│   │   └── ActionBarView.swift           # 수정: Refine/Translate 버튼
│   └── Preferences/
│       ├── PreferencesView.swift         # 수정: 탭 구조
│       └── AISettingsView.swift          # 신규
└── Infrastructure/
    └── (기존과 동일)
```

## 6. DependencyContainer 확장

```swift
@MainActor
final class DependencyContainer {
    // 기존
    let clipboardManager: ClipboardManager
    let globalHotkeyManager: GlobalHotkeyManager
    let floatingPanelController: FloatingPanelController
    let taxonomyRepository: TaxonomyRepository
    let buildPromptUseCase: BuildPromptUseCase
    let draftRepository: PromptDraftRepository
    let promptBuilderViewModel: PromptBuilderViewModel

    // Phase 3 추가
    let keychainRepository: KeychainRepository
    let aiRepositoryProvider: AIRepositoryProvider
    let refinePromptUseCase: RefinePromptUseCase
    let translatePromptUseCase: TranslatePromptUseCase

    init() {
        // ... 기존 초기화 ...
        self.keychainRepository = KeychainRepositoryImpl()

        let openRouter = OpenRouterRepository(keychainRepository: keychainRepository)
        let ollama = OllamaRepository()
        self.aiRepositoryProvider = AIRepositoryProvider(
            openRouter: openRouter,
            ollama: ollama
        )

        // UseCase는 AIRepositoryProvider를 통해 현재 설정에 맞는 구현체를 동적으로 획득
        self.refinePromptUseCase = RefinePromptUseCase(provider: aiRepositoryProvider)
        self.translatePromptUseCase = TranslatePromptUseCase(provider: aiRepositoryProvider)
        // ...
    }
}
```

> **설계 원칙**: `DependencyContainer`는 `AIRepositoryProvider` 하나만 주입한다. Provider 내부에서 설정에 따라 `OpenRouterRepository` / `OllamaRepository`를 스위칭하므로, 설정 변경 시 인스턴스 재생성이 불필요하다. UseCase는 `AIRepository` 프로토콜만 알고 구현체를 모른다.

## 7. 리스크

| 리스크 | 대응 |
|--------|------|
| OpenRouter API 스펙 변경 | response 파싱을 최소 가정으로 유지 (`choices[0].message.content`) |
| Ollama 로컬 미실행 | 연결 실패 시 inline error + "Ollama가 실행 중인지 확인하세요" 안내 |
| API Key 유출 | Keychain만 사용, UserDefaults/파일에 평문 저장 금지 |
| LLM 응답 품질 불안정 | temperature 0.3 (refine), 0.1 (translate) 고정, 사용자 조정 허용 |
| 세션 상태 복잡도 증가 | fingerprint 기반 캐시 + stale 규칙으로 단순화 |

## 8. 참조 문서

- `docs/llm-integration.md` — LLM 통합 계약 (세션 모델, 요청 라이프사이클, 프롬프트 계약)
- `docs/spec.md` §5.4 — LLM Refinement & Translation 기능 정의
- `docs/spec.md` §9 Phase 3 — 마일스톤 정의
