# Phase 1 TODO

목표: 구조화 빌더 기반 UI를 로컬만으로 완성한다.  
범위: 대주제/소주제/키워드/초안 입력/프롬프트 조립/복사까지.  
제외: LLM 다듬기, 영어 번역, 참고 문서 연결.

## 0. 준비

- [x] 현재 Xcode 템플릿 구조 확인
- [x] `docs/spec.md`, `docs/coding.json`, `docs/prompt-examples.md`를 구현 기준선으로 고정
- [x] Phase 1 범위 밖 기능은 구현하지 않기로 명시

완료 기준:
- 구현 시작 전에 "이번 단계에서는 LLM/문서 자산/번역을 하지 않는다"는 범위가 분명해야 함

## 1. 템플릿 제거 및 프로젝트 재구성

- [x] `Item.swift` 제거
- [x] `ContentView.swift` 템플릿 UI 제거
- [x] `floatingboardApp.swift`에서 SwiftData 템플릿 코드 제거
- [x] Feature-First 폴더 구조 생성
- [x] 기본 파일 배치:
  - [x] `App/`
  - [x] `Domain/`
  - [x] `Data/`
  - [x] `Presentation/`
  - [x] `Infrastructure/`
  - [x] `Resources/PromptTaxonomy/`

완료 기준:
- 더 이상 템플릿용 `timestamp`/`NavigationSplitView` 구조가 남아 있지 않음
- 앱 구조가 Prompt Builder 기준으로 재구성됨

## 2. 앱 엔트리와 윈도잉 골격

- [x] 메뉴바 진입 방식 결정
  - [x] `MenuBarExtra` 기반 또는 `NSStatusItem` 기반 중 하나로 확정
- [x] `floatingboardApp.swift`를 메뉴바 앱 구조로 전환
- [x] `FloatingPanel` 또는 `FloatingPanelController` 골격 생성
- [x] 전역 단축키 진입점 파일 생성
- [x] 패널 열기/닫기 기본 동작 연결

완료 기준:
- 앱 실행 시 메뉴바 진입이 가능함
- 단축키 또는 메뉴로 패널을 열고 닫을 수 있음

## 3. 도메인 모델 정의

- [x] `AIProvider` enum 추가
- [x] `Topic`
- [x] `Subtopic`
- [x] `KeywordType`
- [x] `KeywordGroup`
- [x] `KeywordOption`
- [x] `PromptDraft`
- [x] `PromptComposition`

완료 기준:
- `docs/spec.md` 기준 핵심 엔티티가 코드에 존재함
- Phase 1에 불필요한 LLM session/reference snapshot 모델은 아직 넣지 않음

## 4. DependencyContainer 최소 구성

- [x] `DependencyContainer` 생성
- [x] Phase 1에 필요한 객체 생성 책임 연결
  - [x] `TaxonomyRepository`
  - [x] `BuildPromptUseCase`
  - [x] `ClipboardManager`
  - [x] `PromptBuilderViewModel`
- [x] 앱 엔트리에서 container를 주입하는 경로 결정

완료 기준:
- View가 직접 repository를 생성하지 않음
- 최소한의 수동 DI 흐름이 동작함

## 5. Taxonomy 로딩

- [x] `docs/coding.json`을 런타임 리소스로 옮길 경로 결정
  - [x] `Resources/PromptTaxonomy/coding.json`
- [x] `TaxonomyDTO` 정의
- [x] `TaxonomyRepository` 프로토콜 정의
- [x] `LocalTaxonomyRepository` 구현
- [x] JSON 디코딩 테스트 또는 최소 검증 로직 추가

완료 기준:
- 앱이 `coding.json`을 읽어서 메모리 모델로 변환 가능
- subtopic, keyword group, keyword 목록 접근 가능

## 6. Prompt 조립기

- [x] `BuildPromptUseCase` 정의
- [x] `enabledSectionIDs` 반영
- [x] 빈 섹션 생략 규칙 반영
- [x] 키워드 타입별 슬롯 분리
  - [x] `context -> Current Situation`
  - [x] `priority -> Focus / Priorities`
  - [x] `constraint -> Constraints`
  - [x] `output -> Expected Output`
  - [x] `verification -> Verification Requirements`
- [x] `finalInstructionTemplate` 반영
- [x] `User Draft` 원문 보존

완료 기준:
- `docs/prompt-examples.md`의 예시 3개를 대략 재현할 수 있는 base prompt가 생성됨

## 7. PromptBuilderViewModel

- [x] 현재 선택 상태 보관
  - [x] topic
  - [x] subtopic
  - [x] selected keywords
  - [x] user draft text
- [x] subtopic 변경 시 visible keyword 재계산
- [x] 선택 변경 시 base prompt 즉시 재조립
- [x] preview text published state 연결
- [x] copy action 연결

완료 기준:
- 선택 상태가 바뀌면 preview가 즉시 바뀜
- 소주제 변경 시 키워드 후보가 재구성됨

## 8. 최소 UI 골격

- [x] `PromptBuilderView`
- [x] `TopicSelectorView`
- [x] `SubtopicSelectorView`
- [x] `KeywordPickerView`
- [x] `PromptDraftEditorView`
- [x] `PromptPreviewView`
- [x] `ActionBarView`

UI 목표:
- [x] 대주제 1개 노출
- [x] 소주제 단일 선택
- [x] 키워드 클릭 토글
- [x] 멀티라인 초안 입력
- [x] preview 표시
- [x] copy 버튼

완료 기준:
- Phase 1 핵심 플로우를 마우스/키보드로 끝까지 수행 가능

## 9. Clipboard 복사

- [x] `ClipboardManager` 구현
- [x] preview 또는 현재 편집 대상 텍스트 복사
- [x] 복사 성공 상태 표시 방법 결정

완료 기준:
- 복사 버튼 클릭 시 결과가 실제 클립보드에 들어감

## 10. Phase 1 검증

- [x] 앱 실행
- [ ] 메뉴바 진입 확인
- [x] 패널 열기/닫기 확인
- [x] 소주제 선택 확인
- [x] 키워드 선택 확인
- [x] 초안 입력 확인
- [x] preview 즉시 갱신 확인
- [x] 복사 확인
- [ ] `docs/prompt-examples.md` 예시 3개로 수동 검증

완료 기준:
- LLM 없이도 "생각을 좁혀 base prompt를 만들고 복사"하는 제품 가치가 성립함

## 11. Phase 1 이후로 미루는 것

- [ ] LLM refine
- [ ] 영어 번역
- [ ] 참고 문서 연결
- [ ] 최근 작업 복원
- [ ] locale 전환 UI
- [ ] taxonomy 편집 UI

원칙:
- Phase 1 구현 중 위 항목이 새로 끼어들면 범위 확장으로 간주

## 12. Phase 2 목표

목표: 생성된 프롬프트를 바로 검토하고 수정 가능하게 만들고, 앱 재실행 후에도 필요한 상태를 복원한다.  
범위: editable draft, preview/edit mode, 상태 복원, 편집/재조립 충돌 규칙.  
제외: LLM refine, 번역, 참고 문서 연결.

완료 기준:
- 사용자가 base prompt를 직접 수정할 수 있다
- 선택값이 바뀌면 base prompt와 편집본의 관계가 일관되게 유지된다
- 앱 재실행 후 draft와 선택 상태를 복원할 수 있다

## 13. 편집 모델 정의

- [x] `GeneratedPrompt` 또는 동등한 편집 대상 모델 추가
- [x] `base prompt`와 `edited prompt`를 구분하는 상태 모델 정의
- [x] 현재 편집 source-of-truth 규칙 확정
  - [x] base prompt
  - [x] user edited prompt
- [x] 편집 상태 dirty flag 추가

완료 기준:
- "자동 생성 결과"와 "사용자 편집본"이 코드상에서 분리된다

## 14. Preview / Edit 모드 전환

- [x] `PromptPreviewView`를 read-only / editable 모드로 확장
- [x] preview mode에서 selection 기반 결과 표시
- [x] edit mode에서 텍스트 직접 수정 가능
- [x] read-only와 edit mode 전환 UI 추가
- [x] 현재 모드가 무엇인지 명확한 표시 추가

완료 기준:
- 사용자는 generated prompt를 직접 수정하고 다시 볼 수 있다

## 15. 편집/재조립 충돌 규칙

- [ ] 소주제 변경 시 동작 정의
- [ ] 키워드 변경 시 동작 정의
- [ ] 초안 변경 시 동작 정의
- [ ] 편집본이 있는 상태에서 재조립 시 정책 결정
  - [ ] 자동 덮어쓰기 금지
  - [ ] 편집본 유지 + base prompt만 갱신
  - [ ] 필요 시 "Regenerate from selections" 액션 제공
- [ ] stale/generated/edited 상태 표기 방법 정의

완료 기준:
- 사용자가 편집한 내용을 의도치 않게 잃지 않는다
- 선택값 변경 후 어떤 텍스트가 최신인지 항상 알 수 있다

## 16. 상태 복원

- [ ] `PromptDraftRepository` 프로토콜 정의
- [ ] 로컬 저장 구현 (`UserDefaults` 또는 파일) 추가
- [ ] 저장 대상 정의
  - [ ] selected topic
  - [ ] selected subtopic
  - [ ] selected keywords
  - [ ] user draft text
  - [ ] edited prompt text
- [ ] 저장 제외 대상 정의
  - [ ] copy feedback message
  - [ ] panel visibility
  - [ ] 임시 에러 상태
- [ ] 앱 시작 시 복원 연결

완료 기준:
- 앱 재실행 후 Phase 2 범위의 편집 작업을 이어갈 수 있다

## 17. ViewModel 확장

- [ ] `PromptBuilderViewModel`에 editable text 상태 추가
- [ ] generated prompt 업데이트와 edited prompt 유지 규칙 반영
- [ ] restore/save 트리거 추가
- [ ] mode 전환 시 preview text source 변경

완료 기준:
- ViewModel 하나로 preview, edit, restore 흐름이 관리된다

## 18. Phase 2 검증

- [ ] 앱 실행 후 기존 draft 복원 확인
- [x] generated -> edit mode 전환 확인
- [x] edit 후 selection 변경 시 충돌 규칙 확인
- [ ] 앱 재실행 후 edited prompt 복원 확인
- [ ] build 성공
- [ ] targeted tests 추가 및 통과

테스트 후보:
- [x] 편집본 존재 시 selection 변경 규칙 테스트
- [ ] 저장/복원 테스트
- [x] mode 전환 테스트

완료 기준:
- "생성 -> 검토 -> 직접 수정 -> 재실행 후 이어서 작업" 흐름이 성립한다
