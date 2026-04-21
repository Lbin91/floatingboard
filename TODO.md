# FloatingBoard TODO

---

# Phase 1: 구조화 빌더 기반 UI ✅

목표: 구조화 빌더 기반 UI를 로컬만으로 완성한다.  
범위: 대주제/소주제/키워드/초안 입력/프롬프트 조립/복사까지.  
제외: LLM 다듬기, 영어 번역, 참고 문서 연결.

## 0. 준비

- [x] 현재 Xcode 템플릿 구조 확인
- [x] `docs/spec.md`, `docs/coding.json`, `docs/prompt-examples.md`를 구현 기준선으로 고정
- [x] Phase 1 범위 밖 기능은 구현하지 않기로 명시

## 1. 템플릿 제거 및 프로젝트 재구성

- [x] `Item.swift` 제거
- [x] `ContentView.swift` 템플릿 UI 제거
- [x] `floatingboardApp.swift`에서 SwiftData 템플릿 코드 제거
- [x] Feature-First 폴더 구조 생성
- [x] 기본 파일 배치: `App/`, `Domain/`, `Data/`, `Presentation/`, `Infrastructure/`, `Resources/PromptTaxonomy/`

## 2. 앱 엔트리와 윈도잉 골격

- [x] 메뉴바 진입 방식 결정 (`MenuBarExtra`)
- [x] `floatingboardApp.swift`를 메뉴바 앱 구조로 전환
- [x] `FloatingPanel` + `FloatingPanelController` 골격 생성
- [x] 전역 단축키 진입점 파일 생성
- [x] 패널 열기/닫기 기본 동작 연결

## 3. 도메인 모델 정의

- [x] `AIProvider`, `Topic`, `Subtopic`, `KeywordType`, `KeywordGroup`, `KeywordOption`, `PromptDraft`, `PromptComposition`

## 4. DependencyContainer 최소 구성

- [x] `DependencyContainer` 생성
- [x] `TaxonomyRepository`, `BuildPromptUseCase`, `ClipboardManager`, `PromptBuilderViewModel` 연결

## 5. Taxonomy 로딩

- [x] `TaxonomyDTO`, `TaxonomyRepository` 프로토콜, `LocalTaxonomyRepository` 구현

## 6. Prompt 조립기

- [x] `BuildPromptUseCase` 정의 (`enabledSectionIDs`, 빈 섹션 생략, 키워드 타입별 슬롯, `finalInstructionTemplate`, `User Draft` 원문 보존)

## 7. PromptBuilderViewModel

- [x] 선택 상태 보관, subtopic 변경 시 keyword 재계산, base prompt 즉시 재조립, preview text, copy action

## 8. 최소 UI 골격

- [x] `PromptBuilderView`, `TopicSelectorView`, `SubtopicSelectorView`, `KeywordPickerView`, `PromptDraftEditorView`, `PromptPreviewView`, `ActionBarView`

## 9. Clipboard 복사

- [x] `ClipboardManager` 구현, 복사 성공 상태 표시

## 10. Phase 1 검증

- [x] 앱 실행, 패널 열기/닫기, 소주제/키워드/초안/preview/복사 확인
- [x] 빌드 성공, 테스트 통과
- [ ] `docs/prompt-examples.md` 예시 3개로 수동 검증 (구현 후 별도 확인 필요)

---

# Phase 2: 편집과 미리보기 ✅

목표: 생성된 프롬프트를 바로 검토하고 수정 가능하게 만들고, 앱 재실행 후에도 필요한 상태를 복원한다.  
범위: editable draft, preview/edit mode, 상태 복원, 편집/재조립 충돌 규칙.  
제외: LLM refine, 번역, 참고 문서 연결.

## 13. 편집 모델 정의

- [x] `GeneratedPrompt` 모델 추가 (base prompt / edited prompt 분리, dirty flag)

## 14. Preview / Edit 모드 전환

- [x] `PromptPreviewView` read-only / editable 모드 확장
- [x] mode 전환 UI + 현재 모드 표시

## 15. 편집/재조립 충돌 규칙

- [x] 소주제/키워드/초안 변경 시 편집본 유지 + base prompt만 갱신
- [x] "Regenerate from selections" 액션 제공 (`regenerateFromSelections()`)
- [x] stale/generated/edited 상태 표기 (dirty, outdated 배지)

## 16. 상태 복원

- [x] `PromptDraftRepository` 프로토콜 + `LocalPromptDraftRepository` 구현 (UserDefaults)
- [x] 저장 대상: topic, subtopic, keywords, user draft, edited prompt
- [x] 저장 제외: copy feedback, panel visibility, 임시 에러
- [x] `GeneratedPrompt`, `PromptDraft` Codable 채택

## 17. ViewModel 확장

- [x] `saveDraft()`, `restoreDraft()` 메서드 추가
- [x] `DependencyContainer`에 `PromptDraftRepository` 주입
- [x] init 시 `restoreDraft()` 호출

## 18. Phase 2 검증

- [x] 빌드 성공
- [x] 기존 테스트 통과 (8개)
- [x] 저장/복원 테스트 4개 추가 (총 16개 테스트 통과)
- [x] generated → edit mode 전환 확인
- [x] edit 후 selection 변경 시 충돌 규칙 확인
- [ ] 앱 재실행 후 edited prompt 복원 수동 확인
- [ ] panel close 자동 저장 연결 (Phase 3 §25에서 처리)

---

# Phase 3: LLM 다듬기 / 영어 번역 🔜

목표: 구조화 빌더에서 생성된 base prompt를 LLM으로 다듬고(refine), 영어로 번역(translate)하는 기능을 추가한다.  
범위: AI 설정 UI, Refine/Translate UseCase, LLM 세션 상태 관리, Keychain API Key 저장, panel close 자동 저장.  
제외: 참고 문서 연결, 다른 언어 번역, 스트리밍 응답, 세션 간 LLM 결과 복원.

완료 기준:
- LLM 없이도 기본 기능이 그대로 동작한다
- OpenRouter/Ollama 설정 후 Refine/Translate 플로우가 완주된다
- 네트워크 오류 시 inline error 표시, 기존 결과 유지

## 19. Keychain 기반 API Key 관리

- [ ] `KeychainRepository` 프로토콜 정의 (`Domain/Repositories/KeychainRepository.swift`)
  - `func save(key: String, data: Data) throws`
  - `func load(key: String) throws -> Data?`
  - `func delete(key: String) throws`
- [ ] `KeychainRepositoryImpl` 구현 (`Data/Repositories/KeychainRepositoryImpl.swift`)
  - `Security` framework `SecItemAdd` / `SecItemCopyMatching` / `SecItemDelete`
  - `kSecClassGenericPassword`, `kSecAttrService: "com.floatingboard"`
  - `kSecAttrAccount`로 provider 구분 (`openrouter-api-key`, `ollama-endpoint`)
- [ ] 단위 테스트: save → load → delete 라운드트립

완료 기준: API Key를 Keychain에 저장/조회/삭제 가능, 평문 파일에 키 없음

## 20. LLMModelConfig 및 AIProvider 모델 확장

- [ ] `AIProvider` enum 확장 (`Domain/Entities/AIProvider.swift`)
  - 각 provider의 기본 endpoint, 기본 model, 인증 방식 정의
- [ ] `LLMModelConfig` struct 정의 (`Domain/Entities/LLMModelConfig.swift`)
  - `provider`, `modelID`, `endpoint`, `temperature`, `maxTokens`
  - `Equatable`, `Codable` 채택
- [ ] `LLMError` enum 정의 (`Domain/Entities/LLMError.swift`)
  - `apiKeyMissing`, `authenticationFailed`, `timeout`, `rateLimited`, `providerUnavailable`, `malformedResponse`, `cancelled`
  - `LocalizedError` 채택 (한국어 errorDescription)

완료 기준: 모델 설정과 에러 타입이 코드에 존재, Codable로 직렬화 가능

## 21. AIRepository 프로토콜 + Provider 구현체

- [ ] `AIRepository` 프로토콜 정의 (`Domain/Repositories/AIRepository.swift`)
  - `func refine(prompt: String, config: LLMModelConfig) async throws -> String`
  - `func translate(text: String, config: LLMModelConfig) async throws -> String`
- [ ] `OpenRouterRepository` 구현 (`Data/Repositories/OpenRouterRepository.swift`)
  - `URLSession` async/await, endpoint: `https://openrouter.ai/api/v1/chat/completions`
  - 인증: `Authorization: Bearer <api_key>`, timeout: 연결 10초/응답 60초
  - 요청/응답 DTO: `LLMRequest`, `LLMResponse` (`Data/DTOs/`)
- [ ] `OllamaRepository` 구현 (`Data/Repositories/OllamaRepository.swift`)
  - endpoint: 사용자 설정 (기본 `http://localhost:11434/api/chat`), 인증 없음
  - Ollama 응답 파싱 (`message.content`)
- [ ] `AIRepositoryProvider` 구현 (`Data/Repositories/AIRepositoryProvider.swift`)
  - 현재 설정된 `AIProvider`에 따라 적절한 `AIRepository` 구현체를 반환하는 래퍼
  - 내부에 `OpenRouterRepository`, `OllamaRepository` 인스턴스를 모두 보유
  - 설정 변경 시 인스턴스 교체 없이 라우팅만 전환
  - `func resolve(for provider: AIProvider) -> AIRepository`
- [ ] 공통 에러 매핑: HTTP 상태코드 → `LLMError`
- [ ] `RefinePromptUseCase` 구현 (`Domain/UseCases/RefinePromptUseCase.swift`)
  - system prompt: llm-integration.md §11.1 참조
  - `AIRepositoryProvider`를 통해 현재 설정에 맞는 구현체를 동적으로 획득
- [ ] `TranslatePromptUseCase` 구현 (`Domain/UseCases/TranslatePromptUseCase.swift`)
  - 번역 대상 결정 우선순위: `edited text > refined prompt > base prompt`
- [ ] 단위 테스트: DTO 인코딩/디코딩, 에러 매핑

완료 기준: 두 provider 모두 프로토콜 준수, 설정 변경 시 런타임에 Provider 스위칭 가능

## 22. LLM 세션 상태 관리

- [ ] `LLMTaskState` enum 정의 (`Domain/Entities/LLMTaskState.swift`)
  - `idle`, `refining`, `translating`, `completed`, `failed(LLMError)`, `cancelled`, `stale`
- [ ] `PromptBuilderViewModel`에 LLM 상태 추가
  - `llmTaskState: LLMTaskState`, `refinedPrompt: String?`, `translatedPrompt: String?`
  - `activeModelConfig: LLMModelConfig?`
  - 모든 상태 변경은 `@MainActor` 격리 하에서 수행
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

완료 기준: LLM 결과가 stale/cancel 규칙에 따라 일관되게 관리됨

## 23. AI 설정 UI

- [ ] `AISettingsView` 구현 (`Presentation/Preferences/AISettingsView.swift`)
  - Provider 선택: OpenRouter / Ollama (Picker)
  - API Key 입력: SecureField + Keychain 저장 (OpenRouter만)
  - Ollama endpoint 입력: TextField (기본값 `http://localhost:11434`)
  - Model 선택: TextField
  - Temperature 슬라이더 (0.0 ~ 1.0)
  - Max Tokens 입력
  - "Test Connection" 버튼 → 실제 API 호출 후 성공/실패 표시
- [ ] `PreferencesView` 탭 구성: General / AI / Documents / Hotkey
- [ ] 설정 저장: `@AppStorage` + Keychain 혼합
  - Provider, modelID, temperature, maxTokens → `@AppStorage`
  - API Key → Keychain
- [ ] 설정 변경 시 `activeModelConfig` 업데이트 → derived output stale 처리

완료 기준: 설정창에서 AI 구성 후 "Test Connection" 성공 시 응답 표시

## 24. Refine / Translate 액션 UI

- [ ] `ActionBarView`에 Refine / Translate 버튼 추가
  - Refine: `(LLMModelConfig 유효)` 시 활성화, 로딩 스피너, stale 배지
  - Translate: `(source text 존재) AND (LLMModelConfig 유효)` 시 활성화, 로딩 스피너
  - 두 버튼 동시 활성화 불가 (직렬 실행)
- [ ] `PromptPreviewView`에 Refine / Translated 모드 탭 추가
  - `.generated` | `.edited` | `.refined` | `.translated` 4개 모드
  - 배지: BASE, EDITED, REFINED, TRANSLATED, STALE
  - Stale 결과는 warning 색상으로 표시
- [ ] Inline error 표시
  - 실패 시 preview 하단에 error caption (destructive modal 아님)
  - retry는 해당 버튼 재활성화로 제공
- [ ] ViewModel에 `refinePrompt()`, `translatePrompt()` async 메서드 추가
  - `@MainActor` 격리 보장: ViewModel 전체가 이미 `@MainActor`
  - `Task { }`로 비동기 실행, 네트워크 호출만 백그라운드
  - 에러 핸들링 분기:
    - `CancellationError` → `llmTaskState = .cancelled`
    - `LLMError` → `llmTaskState = .failed(error)`, 기존 결과 유지
    - 정상 → `llmTaskState = .completed`

완료 기준: Refine → 로딩 → 결과 → Translate → 영어 번역 결과 표시

## 25. Panel Close 자동 저장

- [ ] `DependencyContainer.showPromptBuilder()`의 `onClose` 콜백 수정
  - 패널 닫기 시 반드시 아래 순서로 실행:
    1. in-flight LLM Task가 있으면 `cancel()` 즉시 발행
    2. `viewModel.saveDraft()` 호출
    3. `floatingPanelController.close()` 호출
  - `@MainActor` 보장하에 순차 실행
- [ ] 테스트: 패널 열기 → 상태 변경 → 패널 닫기 → 재실행 → 상태 복원

완료 기준: 패널 닫은 후 앱 재실행 시 직전 상태 복원

## 26. Phase 3 검증

- [ ] 전체 빌드 성공
- [ ] 기존 테스트 통과
- [ ] 신규 단위 테스트
  - [ ] Refine useCase 단위 테스트 (mock repository)
  - [ ] Translate useCase 단위 테스트
  - [ ] Stale 전파 테스트 (선택값 변경 → refined stale)
  - [ ] Fingerprint 캐시 재사용 테스트
  - [ ] Keychain roundtrip 테스트
  - [ ] ViewModel refine/translate 상태 전이 테스트
  - [ ] CancellationError 분기 테스트
- [ ] 수동 검증
  - [ ] API Key 없이 앱 정상 동작 (기본 기능)
  - [ ] OpenRouter 설정 후 Refine 성공
  - [ ] Ollama 설정 후 Refine 성공
  - [ ] Refine → Translate 플로우
  - [ ] 네트워크 오류 시 inline error 표시
  - [ ] 설정 변경 후 stale 배지 표시

완료 기준: LLM 없이도 기본 기능 동작, LLM 설정 시 refine/translate 플로우 완주

---

# Phase 3 이후로 미루는 것

- [ ] 참고 문서 연결 (Phase 4)
- [ ] locale 전환 UI
- [ ] taxonomy 편집 UI
- [ ] 다른 언어 번역 (영어 외)
- [ ] 스트리밍 응답
- [ ] 세션 간 LLM 결과 복원
- [ ] 채팅 히스토리 기반 대화
