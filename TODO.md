# Phase 1 TODO

목표: 구조화 빌더 기반 UI를 로컬만으로 완성한다.  
범위: 대주제/소주제/키워드/초안 입력/프롬프트 조립/복사까지.  
제외: LLM 다듬기, 영어 번역, 참고 문서 연결.

## 0. 준비

- [ ] 현재 Xcode 템플릿 구조 확인
- [ ] `docs/spec.md`, `docs/coding.json`, `docs/prompt-examples.md`를 구현 기준선으로 고정
- [ ] Phase 1 범위 밖 기능은 구현하지 않기로 명시

완료 기준:
- 구현 시작 전에 "이번 단계에서는 LLM/문서 자산/번역을 하지 않는다"는 범위가 분명해야 함

## 1. 템플릿 제거 및 프로젝트 재구성

- [ ] `Item.swift` 제거
- [ ] `ContentView.swift` 템플릿 UI 제거
- [ ] `floatingboardApp.swift`에서 SwiftData 템플릿 코드 제거
- [ ] Feature-First 폴더 구조 생성
- [ ] 기본 파일 배치:
  - [ ] `App/`
  - [ ] `Domain/`
  - [ ] `Data/`
  - [ ] `Presentation/`
  - [ ] `Infrastructure/`
  - [ ] `Resources/PromptTaxonomy/`

완료 기준:
- 더 이상 템플릿용 `timestamp`/`NavigationSplitView` 구조가 남아 있지 않음
- 앱 구조가 Prompt Builder 기준으로 재구성됨

## 2. 앱 엔트리와 윈도잉 골격

- [ ] 메뉴바 진입 방식 결정
  - [ ] `MenuBarExtra` 기반 또는 `NSStatusItem` 기반 중 하나로 확정
- [ ] `floatingboardApp.swift`를 메뉴바 앱 구조로 전환
- [ ] `FloatingPanel` 또는 `FloatingPanelController` 골격 생성
- [ ] 전역 단축키 진입점 파일 생성
- [ ] 패널 열기/닫기 기본 동작 연결

완료 기준:
- 앱 실행 시 메뉴바 진입이 가능함
- 단축키 또는 메뉴로 패널을 열고 닫을 수 있음

## 3. 도메인 모델 정의

- [ ] `AIProvider` enum 추가
- [ ] `Topic`
- [ ] `Subtopic`
- [ ] `KeywordType`
- [ ] `KeywordGroup`
- [ ] `KeywordOption`
- [ ] `PromptDraft`
- [ ] `PromptComposition`

완료 기준:
- `docs/spec.md` 기준 핵심 엔티티가 코드에 존재함
- Phase 1에 불필요한 LLM session/reference snapshot 모델은 아직 넣지 않음

## 4. DependencyContainer 최소 구성

- [ ] `DependencyContainer` 생성
- [ ] Phase 1에 필요한 객체 생성 책임 연결
  - [ ] `TaxonomyRepository`
  - [ ] `BuildPromptUseCase`
  - [ ] `ClipboardManager`
  - [ ] `PromptBuilderViewModel`
- [ ] 앱 엔트리에서 container를 주입하는 경로 결정

완료 기준:
- View가 직접 repository를 생성하지 않음
- 최소한의 수동 DI 흐름이 동작함

## 5. Taxonomy 로딩

- [ ] `docs/coding.json`을 런타임 리소스로 옮길 경로 결정
  - [ ] `Resources/PromptTaxonomy/coding.json`
- [ ] `TaxonomyDTO` 정의
- [ ] `TaxonomyRepository` 프로토콜 정의
- [ ] `LocalTaxonomyRepository` 구현
- [ ] JSON 디코딩 테스트 또는 최소 검증 로직 추가

완료 기준:
- 앱이 `coding.json`을 읽어서 메모리 모델로 변환 가능
- subtopic, keyword group, keyword 목록 접근 가능

## 6. Prompt 조립기

- [ ] `BuildPromptUseCase` 정의
- [ ] `enabledSectionIDs` 반영
- [ ] 빈 섹션 생략 규칙 반영
- [ ] 키워드 타입별 슬롯 분리
  - [ ] `context -> Current Situation`
  - [ ] `priority -> Focus / Priorities`
  - [ ] `constraint -> Constraints`
  - [ ] `output -> Expected Output`
  - [ ] `verification -> Verification Requirements`
- [ ] `finalInstructionTemplate` 반영
- [ ] `User Draft` 원문 보존

완료 기준:
- `docs/prompt-examples.md`의 예시 3개를 대략 재현할 수 있는 base prompt가 생성됨

## 7. PromptBuilderViewModel

- [ ] 현재 선택 상태 보관
  - [ ] topic
  - [ ] subtopic
  - [ ] selected keywords
  - [ ] user draft text
- [ ] subtopic 변경 시 visible keyword 재계산
- [ ] 선택 변경 시 base prompt 즉시 재조립
- [ ] preview text published state 연결
- [ ] copy action 연결

완료 기준:
- 선택 상태가 바뀌면 preview가 즉시 바뀜
- 소주제 변경 시 키워드 후보가 재구성됨

## 8. 최소 UI 골격

- [ ] `PromptBuilderView`
- [ ] `TopicSelectorView`
- [ ] `SubtopicSelectorView`
- [ ] `KeywordPickerView`
- [ ] `PromptDraftEditorView`
- [ ] `PromptPreviewView`
- [ ] `ActionBarView`

UI 목표:
- [ ] 대주제 1개 노출
- [ ] 소주제 단일 선택
- [ ] 키워드 클릭 토글
- [ ] 멀티라인 초안 입력
- [ ] preview 표시
- [ ] copy 버튼

완료 기준:
- Phase 1 핵심 플로우를 마우스/키보드로 끝까지 수행 가능

## 9. Clipboard 복사

- [ ] `ClipboardManager` 구현
- [ ] preview 또는 현재 편집 대상 텍스트 복사
- [ ] 복사 성공 상태 표시 방법 결정

완료 기준:
- 복사 버튼 클릭 시 결과가 실제 클립보드에 들어감

## 10. Phase 1 검증

- [ ] 앱 실행
- [ ] 메뉴바 진입 확인
- [ ] 패널 열기/닫기 확인
- [ ] 소주제 선택 확인
- [ ] 키워드 선택 확인
- [ ] 초안 입력 확인
- [ ] preview 즉시 갱신 확인
- [ ] 복사 확인
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
