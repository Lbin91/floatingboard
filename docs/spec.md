# Project: FloatingBoard Structured Prompt Builder

## 1. Overview (개요)

FloatingBoard는 macOS 환경에서 전역 단축키로 호출할 수 있는 **구조화된 프롬프트 빌더**입니다. 사용자는 막연한 자유 입력부터 시작하지 않고, 먼저 현재 작업 상황을 선택한 뒤 적절한 작업 유형과 키워드를 단계적으로 고릅니다. 앱은 이 선택값과 사용자의 짧은 초안을 합성해 더 명확하고 강한 프롬프트를 구성하고, 필요하면 LLM으로 다듬거나 영어로 번역한 뒤 클립보드에 복사할 수 있게 합니다.

MVP의 시작점은 넓은 범주의 범용 프롬프트 툴이 아니라, **코딩 작업에 특화된 프롬프트 생성 경험**입니다. 핵심 문제 정의는 "사람들이 프롬프트를 충분히 잘 쓰지 못한다"가 아니라, 더 정확하게는 "**어떻게 잘게 나눠 생각해야 할지 모른다**"입니다. FloatingBoard는 이 사고 분해 과정을 UI로 안내합니다.

### 1.1 Product Goal (제품 목표)
- 코딩 작업을 더 잘게 분해해 AI에게 전달할 수 있도록 돕는다
- 유저가 소수의 선택과 짧은 입력만으로도 질 높은 프롬프트를 만들게 한다
- 프롬프트를 단순 생성이 아닌 **구성, 검토, 수정, 번역, 복사** 가능한 자산으로 다룬다
- 장기적으로는 코딩 외 도메인으로 확장 가능한 프롬프트 조합 엔진을 만든다

### 1.2 MVP Scope
- 대주제는 **`코딩` 하나만 지원**
- 소주제는 **단일 선택**
- 키워드는 클릭 기반으로 수집
- 최종 프롬프트 골격은 **고정 템플릿**
- LLM은 선택값과 초안을 합성해 프롬프트를 더 자연스럽게 정리하는 데 사용
- 완료 결과는 **클립보드 복사**가 기본 종착점

### 1.3 Target Users (타겟 사용자)
- Claude Code, Cursor, VS Code, Codex, ChatGPT, Gemini 등으로 코딩 작업을 자주 하는 개발자
- 구현보다 먼저 "무엇을 어떻게 요청해야 하는지" 정리하는 데 시간을 많이 쓰는 사용자
- 짧고 뭉뚱그린 요구를 더 날카로운 작업 지시로 바꾸고 싶은 사용자
- 한국어로 사고하되 최종 프롬프트는 영어로 보내는 사용 습관이 있는 사용자

### 1.4 Key Differentiators
- **상황 기반 시작점**: 자유 입력이 아니라 `대주제 -> 소주제 -> 키워드` 순서로 사고를 유도
- **집중 강제**: MVP에서는 소주제를 하나만 선택하게 해 프롬프트를 좁고 선명하게 만든다
- **클릭형 사고 수집**: 회원가입 관심사 선택처럼 키워드를 모아 프롬프트의 요구사항을 구조화
- **고정 골격 조립**: 단순 문자열 이어붙이기가 아니라 고정 구조에 맞춰 프롬프트를 조립
- **인간 + LLM 협업 편집**: 자동 생성 후 직접 수정도 가능하고, LLM 다듬기/영문 번역도 가능
- **문서 자산 연결 준비**: 프로젝트 문서, 전역 문서, 외부 Markdown 문서를 추후 참고 자료로 합성 가능

---

## 2. Product Model (제품 모델)

### 2.1 사고 흐름

FloatingBoard는 사용자의 사고를 아래 순서로 분해합니다.

1. **대주제 선택**
2. **소주제 선택**
3. **키워드 수집**
4. **짧은 자유 입력 작성**
5. **고정 골격으로 프롬프트 조립**
6. **직접 수정 또는 LLM 다듬기**
7. **선택적으로 영어 번역**
8. **클립보드 복사**

### 2.2 MVP의 대주제와 소주제

MVP의 대주제는 하나입니다.

| 대주제 | 설명 |
|--------|------|
| `코딩` | 소프트웨어 설계, 수정, 구현, 검증을 위한 프롬프트 작성 |

MVP에서 제공하는 기본 소주제 후보:

| 소주제 | 목적 |
|--------|------|
| 최초 기획 | 새 기능/제품/구조를 처음 설계할 때 |
| 기획 수정 | 기존 방향을 수정하거나 다시 정리할 때 |
| 구현 작업 | 새로운 로직/기능을 실제 코드로 만들 때 |
| 리팩토링 작업 | 동작 보존을 전제로 구조를 정리할 때 |
| 오류 개선 | 버그를 분석하고 수정할 때 |
| 테스트 | 테스트 전략 수립, 테스트 코드 작성, 검증 강화 |
| 기능 추가 | 기존 제품에 새 기능을 안전하게 붙일 때 |
| 기능 삭제 | 기능 제거 범위, 영향도, 정리 작업을 다룰 때 |

> **원칙**: 한 번에 하나의 소주제만 선택. 복합 요청은 나중에 지원하되, MVP는 집중도를 우선한다.

### 2.3 키워드의 의미

UI에서는 모든 키워드가 동일한 "클릭 가능한 칩"처럼 보이지만, 내부적으로는 서로 다른 역할을 가집니다.

| 내부 타입 | 예시 | 프롬프트에서의 역할 |
|-----------|------|---------------------|
| `context` | Swift, React, CLI, API, 테스트 코드 | 현재 작업 대상과 맥락 정의 |
| `priority` | 가독성, 성능, 안정성, 속도 | 무엇을 더 우선할지 지정 |
| `constraint` | 최소 수정, 새 의존성 금지, 기존 스타일 유지 | 변경 범위와 제약 설정 |
| `output` | 코드만, 설명 포함, diff 중심, 단계별 | 원하는 응답 형식 지정 |
| `verification` | 테스트 추가, 원인 설명, 회귀 방지 | 검증과 완료 기준 명시 |

이 구분은 중요합니다. 겉보기에는 모두 태그처럼 보이지만, 실제 프롬프트 조립 시에는 각 타입이 **정해진 슬롯**에 들어가야 결과 품질이 안정됩니다.

### 2.3.1 MVP 키워드 노출 원칙

키워드는 많을수록 좋아 보이지만, 실제로는 선택 피로를 빠르게 증가시킵니다. 따라서 MVP에서는 "모든 가능한 키워드"를 보여주지 않고, **현재 소주제에 가장 관련도 높은 키워드만 제한적으로 노출**합니다.

노출 규칙:
- 한 소주제에서 최초 노출되는 키워드는 **총 8~12개**
- 기본적으로 **3개 그룹까지만 우선 노출**
- 그룹당 기본 노출 수는 **2~4개**
- 나머지 키워드는 `더 보기` 또는 후속 버전의 확장 인터랙션으로 처리
- 노출 키워드는 "자주 쓰이는 기본값"과 "소주제에 특화된 선택지"의 혼합이어야 함

예시:
- `오류 개선`: 원인 설명, 최소 수정, 회귀 방지, 테스트 추가, 로그 기준, Swift, API, UI
- `리팩토링 작업`: 가독성, 구조 단순화, 동작 보존, 새 의존성 금지, diff 중심
- `최초 기획`: 요구사항 정리, 범위 정의, 단계별 계획, 리스크 식별

### 2.4 고정 프롬프트 골격

MVP에서는 최종 프롬프트를 아래 구조로 조립합니다.

1. `Current Situation`
2. `Task Type`
3. `Focus / Priorities`
4. `Constraints`
5. `Expected Output`
6. `Verification Requirements`
7. `User Draft`
8. `References` (문서가 있을 때)
9. `Final Instruction`

UI는 단순하게 보여도, 내부 생성기는 이 섹션 순서를 보존해야 합니다.

단, "고정 골격"은 모든 슬롯을 항상 강제로 채운다는 뜻은 아닙니다.

- 선택되지 않은 슬롯은 생략 가능
- 소주제 성격상 어색한 슬롯은 빈 채로 출력하지 않음
- 예: `기능 삭제`에서 `Verification Requirements`가 비어 있으면 해당 섹션을 만들지 않음
- 예: `최초 기획`에서는 `Expected Output`과 `Final Instruction` 비중이 더 크고, `Constraints`는 선택 기반으로만 생성

### 2.5 확장 방향

MVP 이후 고려할 수 있는 대주제:

- 문서 작성
- 기획
- 리서치
- 커뮤니케이션
- 학습

하지만 초기 버전에서는 **코딩 하나만 밀도 있게 만드는 것**이 우선입니다.

---

## 3. Tech Stack (기술 스택)

### 3.1 Platform & Language
| 항목 | 스펙 | 비고 |
|------|------|------|
| Platform | macOS 14.0+ (Sonoma) | `@Observable`, 최신 SwiftUI 상태 관리와 패널 UI 일관성 확보 |
| Language | Swift 5.9+ | `async/await`, `Actor`, `@Observable` |
| Min Deployment | macOS 14.0 | `@Observable`와 최소 타겟 충돌 제거 |

### 3.2 UI Framework
| 프레임워크 | 용도 | 상세 |
|------------|------|------|
| **SwiftUI** | Prompt Builder UI, 설정창, 프롬프트 편집기 | `Settings` scene, `TabView`, chip-like controls |
| **AppKit** | Floating Panel, 메뉴바 연동, 파일 선택기 보강 | `NSPanel`, `NSStatusItem`, `NSOpenPanel` |

#### NSPanel 상세 스펙
```swift
class FloatingPanel: NSPanel {
    // StyleMask: titled + fullSizeContentView
    // level: .floating
    // canBecomeKey: true
    // titlebarAppearsTransparent: true
    // contentView: NSHostingView(rootView: PromptBuilderView)
}
```

> **MVP 방향 변화**: Floating Panel은 여전히 핵심 진입점이지만, 역할은 "즉시 실행형 입력창"이 아니라 "빠르게 호출되는 구조화 빌더"입니다.

### 3.3 Networking
| 항목 | 스펙 |
|------|------|
| HTTP Client | `URLSession` + `async/await` |
| API 스타일 | JSON POST 기반 비스트리밍 우선 |
| JSON | `Foundation.JSONDecoder` / `JSONEncoder` |
| Timeout | 연결 10초, 응답 60초 |

> 초기 버전의 LLM 사용 목적은 채팅형 상호작용이 아니라, **선택값 + 초안 -> 더 좋은 프롬프트**로 정리하는 단일 작업입니다. 스트리밍은 필수가 아닙니다.

### 3.4 System Integration
| API | 용도 | 상세 |
|-----|------|------|
| `NSPasteboard` | 최종 프롬프트 복사 | `generalPasteboard()` |
| `NSOpenPanel` | 외부 Markdown 문서 선택 | 보안 범위 북마크와 함께 사용 |
| Security-scoped bookmark | 외부 파일 접근 유지 | 프로젝트 외부 문서 참조 |
| `FileManager` | 로컬 문서, taxonomy, draft 저장 | 앱 지원 디렉토리 기반 |

### 3.5 Security
| 항목 | 스펙 |
|------|------|
| API Key 저장 | `Security` framework 기반 Keychain Services |
| 외부 파일 접근 | Security-scoped bookmark로 최소 권한 유지 |
| 사용자 초안 저장 | 명시적 저장 시에만 로컬 저장 |
| 디버그 로그 | 프롬프트 원문 로그 기본 비활성화 |

### 3.6 Global Hotkey
| 접근 방식 | 권한 필요 | 비고 |
|-----------|-----------|------|
| **Carbon `RegisterEventHotKey`** (권장) | 불필요 | 메뉴바 유틸리티 스타일과 궁합이 좋음 |
| `KeyboardShortcuts` | 불필요 | 단축키 Recorder UI 제공 |

### 3.7 Data Persistence
| 항목 | 방식 | 용도 |
|------|------|------|
| API Keys | Keychain | LLM 다듬기/번역용 API Key |
| Prompt Taxonomy | 번들 JSON + 사용자 확장 JSON | 대주제/소주제/키워드 데이터 |
| Prompt Draft | 로컬 파일 또는 `UserDefaults` | 최근 입력 복원 |
| Reference Documents | 파일 시스템 + bookmark | 프로젝트/전역/외부 Markdown |
| 앱 설정 | `@AppStorage` 또는 JSON | 단축키, 기본 동작, LLM 옵션 |

#### Prompt Taxonomy Contract

`coding.json`은 단순한 라벨 모음이 아니라, UI 노출과 프롬프트 조립을 동시에 제어하는 선언형 계약입니다.

최소 포함 필드:
- `topics`
- `subtopics`
- `keywordGroups`
- `keywords`
- `visibilityRules`
- `assemblyRules`

이 계약은 세 가지를 동시에 해결해야 합니다.

1. 어떤 소주제에서 어떤 키워드를 기본 노출할지
2. 각 키워드가 어떤 슬롯으로 들어갈지
3. 특정 소주제에서 어떤 프롬프트 섹션을 우선하거나 생략할지

---

## 4. Architecture (아키텍처)

### 4.1 Feature-First 구조

```
FloatingBoard/
├── App/
│   ├── FloatingBoardApp.swift
│   ├── AppDelegate.swift
│   └── DependencyContainer.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── Topic.swift
│   │   ├── Subtopic.swift
│   │   ├── KeywordOption.swift
│   │   ├── PromptDraft.swift
│   │   ├── PromptComposition.swift
│   │   ├── ReferenceDocument.swift
│   │   └── AIProvider.swift
│   ├── UseCases/
│   │   ├── LoadPromptTaxonomyUseCase.swift
│   │   ├── BuildPromptUseCase.swift
│   │   ├── RefinePromptUseCase.swift
│   │   ├── TranslatePromptUseCase.swift
│   │   └── ManageReferenceDocumentsUseCase.swift
│   └── Repositories/
│       ├── TaxonomyRepository.swift
│       ├── AIRepository.swift
│       ├── PromptDraftRepository.swift
│       ├── ReferenceDocumentRepository.swift
│       └── KeychainRepository.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── LocalTaxonomyRepository.swift
│   │   ├── OpenRouterRepository.swift
│   │   ├── OllamaRepository.swift
│   │   ├── LocalPromptDraftRepository.swift
│   │   ├── LocalReferenceDocumentRepository.swift
│   │   └── KeychainRepositoryImpl.swift
│   └── DTOs/
│       ├── LLMRefineRequest.swift
│       ├── LLMRefineResponse.swift
│       └── TaxonomyDTO.swift
│
├── Presentation/
│   ├── PromptBuilder/
│   │   ├── PromptBuilderView.swift
│   │   ├── PromptBuilderViewModel.swift
│   │   ├── TopicSelectorView.swift
│   │   ├── SubtopicSelectorView.swift
│   │   ├── KeywordPickerView.swift
│   │   ├── PromptDraftEditorView.swift
│   │   ├── PromptPreviewView.swift
│   │   └── ActionBarView.swift
│   ├── ReferenceDocuments/
│   │   ├── ReferenceDocumentPickerView.swift
│   │   └── ReferenceDocumentViewModel.swift
│   ├── Preferences/
│   │   ├── PreferencesView.swift
│   │   ├── AISettingsView.swift
│   │   ├── DocumentSettingsView.swift
│   │   ├── TaxonomySettingsView.swift
│   │   └── HotkeySettingsView.swift
│   └── MenuBar/
│       └── MenuBarView.swift
│
├── Infrastructure/
│   ├── Hotkey/
│   │   └── GlobalHotkeyManager.swift
│   ├── Clipboard/
│   │   └── ClipboardManager.swift
│   ├── FileAccess/
│   │   ├── BookmarkStore.swift
│   │   └── MarkdownDocumentLoader.swift
│   └── Windowing/
│       └── FloatingPanelController.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── PromptTaxonomy/
    │   └── coding.json
    └── Localizable.xcstrings
```

### 4.2 데이터 흐름

```
User Selection (Topic / Subtopic / Keywords / Draft)
    ↓
PromptBuilderViewModel
    ↓
BuildPromptUseCase
    ↓
PromptComposition
    ↓
Optional: RefinePromptUseCase / TranslatePromptUseCase
    ↓
PromptPreview
    ↓
ClipboardManager.copy()
```

### 4.3 설계 원칙
- UI는 단순 클릭형이어야 하지만, 내부 모델은 구조적이어야 한다
- 키워드는 모두 같은 칩처럼 보여도 내부적으로 타입이 있어야 한다
- 프롬프트 품질은 LLM 자체보다 **사전 구조화 품질**에 더 크게 좌우된다
- LLM은 필수가 아니라, 구조화된 초안을 더 매끄럽게 만드는 보조 단계다
- 대주제와 소주제는 나중에 늘어나더라도 조립 엔진은 그대로 재사용 가능해야 한다

---

## 5. Core Features (핵심 기능)

### 5.1 Prompt Context Selection

#### 대주제 선택
- MVP에서는 `코딩` 하나만 제공
- UI에서는 하나만 보이더라도, 추후 확장 가능한 구조로 구현
- 선택 상태는 상단 breadcrumb 또는 chip으로 항상 표시

#### 소주제 선택
- 소주제는 반드시 하나만 선택
- 선택 후 하위 키워드 후보가 재계산됨
- 소주제를 바꾸면 키워드는 초기화하되, 자유 입력은 유지

기본 소주제:
- 최초 기획
- 기획 수정
- 구현 작업
- 리팩토링 작업
- 오류 개선
- 테스트
- 기능 추가
- 기능 삭제

### 5.2 Keyword Collection

#### 키워드 그룹
MVP 기본 그룹:

| 그룹 | 설명 | 예시 |
|------|------|------|
| 작업 대상 | 무엇을 다루는지 | 함수, 파일, 컴포넌트, API, 테스트 |
| 우선순위 | 무엇을 더 중시하는지 | 가독성, 안정성, 성능, 속도 |
| 제약조건 | 무엇을 지켜야 하는지 | 최소 수정, 새 의존성 금지, 기존 스타일 유지 |
| 출력 방식 | 어떤 응답을 원하는지 | 코드만, 설명 포함, diff 중심, 단계별 |
| 검증 요구 | 완료 기준 | 테스트 추가, 회귀 방지, 원인 설명 |

#### 동작 원칙
- 유저는 관심사 선택처럼 여러 키워드를 클릭 가능
- 내부적으로는 `context / priority / constraint / output / verification` 슬롯에 매핑
- 일부 키워드는 특정 소주제에서만 노출
- 잘못된 조합은 비활성화 또는 경고로 처리
- 최초 노출 키워드는 소주제당 총 8~12개 범위를 유지
- 고빈도 키워드는 기본 노출, 저빈도 키워드는 점진적 공개가 원칙

### 5.3 Prompt Draft & Composition

#### 자유 입력
- 유저는 짧은 초안만 작성하면 됨
- 예: "SwiftUI 설정 화면에서 API 키 저장 구조를 정리하고 싶다"
- 초안은 구조화되지 않아도 됨

#### 프롬프트 조립
앱은 아래 입력값을 결합해 고정 골격 프롬프트를 생성:

1. 대주제
2. 소주제
3. 선택된 키워드
4. 사용자 자유 입력
5. 선택된 참고 문서

#### 직접 수정
- 생성된 프롬프트는 사용자가 바로 편집 가능
- 사용자가 일부를 지웠더라도, 구조는 다시 재조립 가능해야 함

### 5.4 LLM Refinement & Translation

#### LLM 다듬기
- 선택값과 초안을 바탕으로 더 좋은 프롬프트 문장으로 정리
- 새 정보를 임의로 추가하기보다, 선택된 의도를 더 명확하게 풀어쓰는 역할
- LLM 사용은 옵션이며, 오프라인/무설정 상태에서도 기본 프롬프트 생성은 가능해야 함

#### 영어 번역
- 최종 프롬프트를 영어로 변환하는 옵션 제공
- 번역 시 원문 의도와 구조를 최대한 유지
- 원문/영문 전환 UI 필요

### 5.5 Reference Documents (문서 자산)

MVP에서 완전한 문서 시스템까지 포함할지는 구현 상황을 보며 조정할 수 있지만, 제품 모델은 지금부터 반영합니다.

지원 대상:
- 프로젝트 내부 Markdown 문서
- 전역 공통 Markdown 문서
- 외부 파일로 선택한 Markdown 문서

문서의 역할:
- 프로젝트 규칙
- 코딩 스타일
- 작업 참고 메모
- 기능 배경 문서
- 반복적으로 붙이고 싶은 팀 프롬프트 자산

문서 적용 방식:
- 대주제 선택 전 기본 세트 구성 가능
- 이후 단계에서도 문서 추가/제거 가능
- 최종 프롬프트에는 `References` 섹션으로 반영

### 5.6 Output & Clipboard

- 최종 결과는 클립보드 복사가 기본
- `복사`, `영문 복사`, `원문 복사` 액션 지원 고려
- 향후 "최근 프롬프트 기록" 기능 확장 가능

---

## 6. UI/UX Flow (사용자 경험 흐름)

### 6.1 최초 실행 플로우
```
[앱 실행]
  → [메뉴바 아이콘 표시]
    → [단축키 안내]
      → [선택 사항: AI 설정]
        → (설정 안 함) 기본 프롬프트 생성 기능은 사용 가능
        → (설정 함) 다듬기 / 번역 기능 활성화
```

> **중요**: API Key가 없어도 앱의 기본 가치가 작동해야 합니다.

### 6.2 일반 사용 플로우
```
1. [작업 중] → 단축키 실행
2. [Floating Panel 표시]
3. [대주제 선택] → 코딩
4. [소주제 선택] → 예: 오류 개선
5. [키워드 클릭] → 우선순위/제약/출력/검증 요구 수집
6. [짧은 초안 입력]
7. [선택 사항: 참고 문서 추가]
8. [프롬프트 생성]
9. [직접 수정 또는 LLM 다듬기]
10. [선택 사항: 영어 번역]
11. [복사]
```

### 6.3 수정 가능 구조
- 대주제, 소주제, 키워드는 언제든 다시 수정 가능
- 이전 선택을 바꿔도 초안 텍스트는 가능한 한 보존
- 소주제를 바꾸면 키워드 목록은 재구성
- 문서 첨부는 흐름 중간에도 추가/삭제 가능
- 프롬프트 미리보기는 항상 현재 선택 상태를 반영

### 6.4 설정창 플로우
- 메뉴바 아이콘 클릭 → "Preferences..." 또는 `Cmd + ,`
- 탭 구성:
  - **일반**: 단축키, 패널 동작, 기본 복사 동작
  - **AI 설정**: OpenRouter / Ollama, 모델, 번역 옵션
  - **문서 자산**: 전역 Markdown 등록, 북마크 관리
  - **Taxonomy 관리**: 향후 대주제/소주제/키워드 편집용
  - **기록**: 최근 생성 프롬프트 보기 (후속 버전)

---

## 7. Non-Functional Requirements (비기능 요구사항)

### 7.1 Performance
| 항목 | 기준 |
|------|------|
| 단축키 → 패널 표시 | ≤ 100ms |
| 패널 표시 → 첫 선택 가능 상태 | ≤ 50ms |
| 키워드 선택 반응 | ≤ 50ms |
| 프롬프트 재조립 | ≤ 100ms |
| 복사 완료 반응 | ≤ 50ms |
| 메모리 사용량 | ≤ 80MB (유휴 상태) |

### 7.2 Security
| 항목 | 정책 |
|------|------|
| API Key 저장 | Keychain |
| 문서 접근 | 북마크 기반 최소 권한 유지 |
| 네트워크 | LLM 요청 시에만 외부 전송 |
| 로깅 | 원문 프롬프트/문서 내용 기본 저장 안함 |

### 7.3 Accessibility
| 항목 | 정책 |
|------|------|
| 키보드 탐색 | 모든 선택 흐름 키보드만으로 가능 |
| VoiceOver | 대주제, 소주제, 키워드, 액션 라벨 제공 |
| 대비 | WCAG 2.1 AA 이상 |
| 포커스 상태 | 현재 단계와 선택 항목 명확히 표시 |

### 7.4 Reliability
| 항목 | 정책 |
|------|------|
| LLM 연결 실패 | 기본 프롬프트 생성은 계속 가능 |
| 문서 파일 누락 | 경고 표시 후 해당 문서만 제외 |
| taxonomy 손상 | 번들 기본값으로 복구 |
| 앱 재시작 | 마지막 초안/선택 상태 선택적 복원 |

---

## 8. Data Models (데이터 모델)

### 8.1 Core Entities
```swift
enum TopicID: String, Codable, CaseIterable {
    case coding
}

struct Topic: Identifiable, Codable {
    let id: TopicID
    let title: String
    let summary: String
}

struct Subtopic: Identifiable, Codable {
    let id: String
    let topicID: TopicID
    let title: String
    let description: String
    let keywordGroupIDs: [String]
    let defaultKeywordIDs: [String]
    let enabledSectionIDs: [String]
}

enum KeywordType: String, Codable {
    case context
    case priority
    case constraint
    case output
    case verification
}

struct KeywordOption: Identifiable, Codable {
    let id: String
    let groupID: String
    let type: KeywordType
    let title: String
    let promptFragment: String
    let isPrimary: Bool
    let supportedSubtopicIDs: [String]
}

struct KeywordGroup: Identifiable, Codable {
    let id: String
    let title: String
    let displayOrder: Int
    let maxVisibleKeywords: Int
}

struct PromptDraft: Codable {
    var topicID: TopicID
    var subtopicID: String?
    var selectedKeywordIDs: [String]
    var userInput: String
    var selectedReferenceDocumentIDs: [UUID]
}

enum ReferenceDocumentScope: String, Codable {
    case global
    case project
    case external
}

struct ReferenceDocument: Identifiable, Codable {
    let id: UUID
    var title: String
    var path: String
    var scope: ReferenceDocumentScope
    var isEnabled: Bool
}

struct PromptComposition {
    let currentSituation: String
    let taskType: String
    let priorities: [String]
    let constraints: [String]
    let expectedOutput: [String]
    let verificationRequirements: [String]
    let userDraft: String
    let references: [ReferenceDocument]
}
```

### 8.2 Taxonomy JSON 예시

```json
{
  "topics": [
    {
      "id": "coding",
      "title": "코딩",
      "summary": "소프트웨어 설계, 수정, 구현, 검증을 위한 프롬프트 작성"
    }
  ],
  "subtopics": [
    {
      "id": "bugfix",
      "topicID": "coding",
      "title": "오류 개선",
      "description": "버그를 분석하고 수정할 때",
      "keywordGroupIDs": ["context", "constraint", "verification"],
      "defaultKeywordIDs": ["swift", "root-cause-first", "minimal-change", "regression-test"],
      "enabledSectionIDs": ["situation", "taskType", "constraints", "verification", "userDraft", "finalInstruction"]
    }
  ],
  "keywordGroups": [
    {
      "id": "constraint",
      "title": "제약조건",
      "displayOrder": 2,
      "maxVisibleKeywords": 4
    }
  ],
  "keywords": [
    {
      "id": "minimal-change",
      "groupID": "constraint",
      "type": "constraint",
      "title": "최소 수정",
      "promptFragment": "Keep the change set minimal and localized.",
      "isPrimary": true,
      "supportedSubtopicIDs": ["bugfix", "refactor", "feature-delete"]
    }
  ]
}
```

### 8.3 App Settings
```swift
struct AppSettings: Codable {
    var globalHotkey: String
    var launchAtLogin: Bool
    var copyBehavior: CopyBehavior
    var panelOpacity: Double
    var restoreLastDraftOnLaunch: Bool
    var preferredLLMProvider: AIProvider?
    var defaultTranslationLanguage: String
}
```

### 8.4 Prompt Assembly Contract

조립기는 반드시 아래 규칙을 지켜야 합니다.

- `subtopic`은 하나만 허용
- 키워드는 타입별 슬롯에 분리
- 자유 입력은 가공 전 원문도 보존
- LLM 다듬기 전/후 결과를 구분 가능해야 함
- 번역 결과는 원문과 별도 버전으로 유지 가능해야 함
- `enabledSectionIDs`에 없는 섹션은 출력하지 않음
- 빈 슬롯 제목만 남는 출력은 허용하지 않음

---

## 9. Phased Milestone (개발 단계)

### Phase 1: 구조화 빌더 기반 UI
**목표**: 대주제/소주제/키워드/초안 입력/복사 흐름을 로컬만으로 완성
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| Floating Panel 구현 | `FloatingPanel` + SwiftUI 호스팅 | 패널 호출/닫기 정상 |
| 기본 Prompt Builder UI | 대주제/소주제/키워드/초안 입력 | 전체 선택 흐름 동작 |
| Prompt Taxonomy | `coding.json` | 샘플 데이터 로드 성공 |
| Prompt 조립기 | `BuildPromptUseCase` | 고정 골격 프롬프트 생성 |
| Clipboard 복사 | `ClipboardManager` | 결과 복사 성공 |

### Phase 2: 편집과 미리보기
**목표**: 생성된 프롬프트를 바로 검토하고 수정 가능하게 만들기
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| Prompt Preview | 미리보기 패널 | 선택값 변경 시 즉시 반영 |
| Editable Draft | 직접 수정 가능한 편집기 | 생성 결과 수동 수정 가능 |
| 상태 복원 | 최근 draft 저장 | 앱 재실행 시 복원 가능 |

### Phase 3: LLM 다듬기 / 번역
**목표**: LLM 보조 기능 추가
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| AI 설정 | OpenRouter/Ollama 구성 | 연결 테스트 성공 |
| RefinePromptUseCase | 프롬프트 다듬기 | 선택값 기반 개선 결과 생성 |
| TranslatePromptUseCase | 영어 번역 | 원문 의미 유지 |
| 에러 처리 | 네트워크/인증 오류 UI | 실패 시 로컬 기능 유지 |

### Phase 4: 문서 자산 연결
**목표**: Markdown 기반 참고 자료를 프롬프트에 반영
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| 문서 등록 | 전역/프로젝트/외부 문서 선택 | 문서 목록 관리 가능 |
| 보안 북마크 | 외부 파일 권한 유지 | 앱 재실행 후 재접근 가능 |
| References 합성 | Prompt 조립기 확장 | 문서가 프롬프트에 반영 |

### Phase 5: 안정화 및 확장 준비
**목표**: 제품 품질 강화와 다주제 확장 준비
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| 키보드 UX 개선 | 전체 흐름 키보드 조작 | 포커스 이동 자연스러움 |
| Taxonomy 확장성 | JSON schema 정리 | 신규 대주제 추가 가능 |
| 테스트 보강 | Domain / Presentation 테스트 | 핵심 흐름 안정성 확보 |

---

## 10. Risks & Mitigations (리스크 및 대응)

| 리스크 | 확률 | 영향 | 대응 방안 |
|--------|------|------|-----------|
| 키워드가 많아져 UI가 복잡해짐 | 높음 | 높음 | 소주제별로 키워드 그룹 제한, 기본 추천 우선 노출 |
| 조합식 프롬프트가 기계적으로 보임 | 중간 | 높음 | LLM 다듬기 옵션 제공, 내부 템플릿 문장 품질 개선 |
| LLM이 선택되지 않은 요구를 임의로 보강 | 중간 | 중간 | "선택된 정보만 명확화" 규칙을 시스템 프롬프트에 명시 |
| 문서 자산이 길어져 토큰이 과도해짐 | 중간 | 높음 | 문서 선택 수 제한, 길이/요약 정책 도입 |
| 사용자 초안이 너무 짧아 품질이 낮음 | 높음 | 중간 | placeholder, 예시, 추천 키워드로 보완 |
| taxonomy 설계가 도메인별로 커짐 | 중간 | 중간 | JSON 기반 선언형 구조 유지 |

---

## 11. Testing Strategy (테스트 전략)

| 레이어 | 테스트 유형 | 도구 | 커버리지 목표 |
|--------|------------|------|--------------|
| Domain | 단위 테스트 | XCTest | 90%+ |
| Taxonomy | 스냅샷/검증 테스트 | XCTest | 핵심 조합 검증 |
| Presentation (ViewModel) | 상태 전이 테스트 | XCTest | 80%+ |
| Integration | LLM refine/translate 통합 테스트 | XCTest | 핵심 플로우 |
| UI | 수동 + UI Test | XCTest / 수동 | 주요 시나리오 |

### 테스트 우선순위
1. **Prompt 조립 로직 테스트**: 소주제/키워드가 올바른 슬롯에 들어가는지 검증
2. **소주제별 키워드 노출 테스트**: 잘못된 조합이 섞이지 않는지 검증
3. **편집/재조립 테스트**: 선택값 변경 시 미리보기가 올바르게 갱신되는지 검증
4. **복사 테스트**: 원문/영문 결과가 정확히 복사되는지 검증
5. **문서 자산 테스트**: 파일 누락, bookmark 복원, references 반영 검증
