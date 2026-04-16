# Project: Floating AI Prompt Assistant

## 1. Overview (개요)

macOS 환경에서 전역 단축키로 호출할 수 있는 '항상 위에 떠 있는(Floating)' 텍스트 입력 유틸리티입니다. 사용자의 짧은 지시문이나 한국어 입력을 OpenRouter 또는 Local LLM(Ollama 등)을 통해 풍부한 프롬프트로 확장(Enrich)하거나 번역합니다. 처리된 텍스트는 작업 중이던 터미널(Claude Code CLI 등)이나 개발 환경(Cursor, VS Code 등)에 자동으로 입력되어 개발 및 작업 생산성을 극대화합니다.

### 1.1 Target Users (타겟 사용자)
- Claude Code CLI, Cursor, VS Code 등을 사용하는 개발자
- AI 어시스턴트에 프롬프트를 빈번하게 입력하는 사용자
- 한국어-영문 프롬프트 번역/확장이 필요한 사용자

### 1.2 Key Differentiators
- Spotlight 스타일의 미니멀한 Floating UI — 작업 흐름 방해 최소화
- Auto-Injection: AI 응답을 타겟 앱에 자동 붙여넣기
- 커스텀 Skill 시스템: 사용자 정의 프롬프트 템플릿 관리
- OpenRouter + Ollama 듀얼 백엔드 지원

---

## 2. Tech Stack (기술 스택)

### 2.1 Platform & Language
| 항목 | 스펙 | 비고 |
|------|------|------|
| Platform | macOS 13.0+ (Ventura) | `MenuBarExtra`, `.toolbar` SwiftUI API 활용 |
| Language | Swift 5.9+ | `async/await`, `Actor` 등 최신 Concurrency 활용 |
| Min Deployment | macOS 13.0 | `NSPanel` 안정성, `MenuBarExtra` 가용성 확보 |

### 2.2 UI Framework
| 프레임워크 | 용도 | 상세 |
|------------|------|------|
| **SwiftUI** | 사용자 인터페이스, 환경설정(Preferences) | `MenuBarExtra`, `Settings` scene, `@Observable` macro |
| **AppKit** | 메인 Floating 윈도우 제어 | `NSPanel` subclass, `NSStatusItem` (메뉴바 아이콘) |

#### NSPanel 상세 스펙
```swift
// FloatingPanel 핵심 설정
class FloatingPanel: NSPanel {
    // StyleMask: nonactivatingPanel (포커스 탈취 방지) + titled + fullSizeContentView
    // level: .floating (일반 윈도우 위에 표시)
    // becomesKeyOnlyIfNeeded: false (텍스트 입력을 위해 키 윈도우 필요)
    // isFloatingPanel: true
    // hidesOnDeactivate: false
    // collectionBehavior: [.fullScreenAuxiliary, .canJoinAllSpaces]
    // backgroundColor: .clear, isOpaque: false (투명 배경)
    // titlebarAppearsTransparent: true, titleVisibility: .hidden
    // canBecomeKey: true override (텍스트 필드 포커스 허용)
    // contentView: NSHostingView(rootView: SwiftUI View)
}
```

> **중요**: `becomesKeyOnlyIfNeeded`는 텍스트 입력이 필요하므로 `false`로 설정. `canBecomeKey`는 반드시 `true` override 필요 (기본값이 `false`이므로 텍스트 입력 불가).

### 2.3 Networking
| 항목 | 스펙 |
|------|------|
| HTTP Client | `URLSession` + `async/await` |
| SSE (Server-Sent Events) | `URLSessionWebSocketTask` 또는 manual SSE 파싱 (`URLInputStream`) |
| JSON | `Foundation.JSONDecoder` / `JSONEncoder` |
| Timeout | 연결 10초, 응답 120초 (스트리밍 고려) |

### 2.4 System Integration
| API | 용도 | 상세 |
|-----|------|------|
| `NSWorkspace` | 타겟 앱 추적 및 포커스 복귀 | `frontmostApplication` 참조 보관 → `activate()` 복원 |
| `CGEvent` (`CoreGraphics`) | 자동 타이핑 이벤트 전송 | `CGEvent(keyboardEventSource:virtualKey:)` → `CGEventPost(.cghidEventTap, event)` |
| `NSPasteboard` | 클립보드 읽기/쓰기 | `generalPasteboard()`, 임시 복사 후 복원 로직 |
| `AXIsProcessTrusted()` | 접근성 권한 확인 | `kAXTrustedCheckOptionPrompt` 옵션 |

### 2.5 Security
| 항목 | 스펙 |
|------|------|
| API Key 저장 | `Security` framework (`SecItemAdd` / `SecItemCopyMatching`) — Keychain Services |
| 저장 키 | 서비스명: `com.floatingboard.apikeys`, 계정: `openrouter` / `ollama` |
| 대안 라이브러리 | [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) (SPM) — 검증된 래퍼 |

### 2.6 Global Hotkey
| 접근 방식 | 권한 필요 | 비고 |
|-----------|-----------|------|
| **Carbon `RegisterEventHotKey`** (권장) | 불필요 | Electron, VS Code, Slack 등에서 검증됨. Deprecated이나 Apple의 대체 API 미제공 |
| `NSEvent.addGlobalMonitorForEvents` | Accessibility 권한 필요 | 키로거와 유사한 광범위 모니터링 — 권한 게이트 있음 |
| `CGEventTap` | Input Monitoring 권한 필요 | TCC 명시적 연동 (`CGPreflightListenEventAccess`) |

> **결정**: Carbon `RegisterEventHotKey` 기반 래퍼 사용.
> - 추천 라이브러리: [HotKey](https://github.com/soffes/HotKey) (v0.2.1, SPM, 1,070+ stars) 또는 [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) (v2.4.0, SPM, 커스텀 단축키 녹화 UI 포함)
> - Electron, VS Code 등에서 동일 방식 사용 중

### 2.7 Data Persistence
| 항목 | 방식 | 용도 |
|------|------|------|
| API Keys | Keychain (암호화) | OpenRouter API Key, Ollama Endpoint URL |
| Skill 데이터 | `UserDefaults` 또는 `FileManager` (JSON) | 사용자 정의 프롬프트 템플릿 |
| 앱 설정 | `@AppStorage` (UserDefaults) | 단축키, 기본 Skill, 창 위치 등 |

---

## 3. Architecture (아키텍처)

### 3.1 Clean Architecture + Feature-First 구조

```
FloatingBoard/
├── App/                          # Application Layer
│   ├── FloatingBoardApp.swift    # @main 진입점, MenuBarExtra, Settings scene
│   ├── AppDelegate.swift         # NSPanel 생명주기 관리
│   └── DependencyContainer.swift # DI 컨테이너 (Composition Root)
│
├── Domain/                       # Domain Layer (순수 Swift, 외부 의존성 없음)
│   ├── Entities/
│   │   ├── Skill.swift           # Skill 모델 (id, name, systemPrompt, icon)
│   │   ├── AIProvider.swift      # Provider enum (.openRouter, .ollama)
│   │   └── PromptResult.swift    # AI 응답 결과 모델
│   ├── UseCases/
│   │   ├── EnrichPromptUseCase.swift    # 프롬프트 확장
│   │   ├── TranslatePromptUseCase.swift # 번역
│   │   └── ManageSkillsUseCase.swift    # Skill CRUD
│   └── Repositories/             # Protocol (인터페이스만 정의)
│       ├── AIRepository.swift           # AI 통신 추상화
│       ├── SkillRepository.swift        # Skill 저장소 추상화
│       └── KeychainRepository.swift     # Keychain 추상화
│
├── Data/                         # Data Layer
│   ├── Repositories/             # Domain Repository 구현체
│   │   ├── OpenRouterRepository.swift
│   │   ├── OllamaRepository.swift
│   │   ├── LocalSkillRepository.swift
│   │   └── KeychainRepositoryImpl.swift
│   ├── DTOs/
│   │   ├── OpenRouterRequest.swift
│   │   ├── OpenRouterResponse.swift
│   │   ├── OllamaRequest.swift
│   │   └── OllamaResponse.swift
│   └── Network/
│       ├── URLSession+Extensions.swift
│       └── SSEParser.swift              # Server-Sent Events 파서
│
├── Presentation/                 # Presentation Layer
│   ├── FloatingPanel/            # Feature: 메인 Floating UI
│   │   ├── FloatingPanelView.swift
│   │   ├── FloatingPanelViewModel.swift
│   │   └── FloatingPanelController.swift  # NSPanel 서브클래스
│   ├── Preferences/              # Feature: 설정 화면
│   │   ├── PreferencesView.swift
│   │   ├── PreferencesViewModel.swift
│   │   ├── APIKeySettingsView.swift
│   │   └── SkillManagementView.swift
│   ├── Shared/
│   │   ├── Components/           # 재사용 UI 컴포넌트
│   │   │   ├── SkillButton.swift
│   │   │   ├── LoadingIndicator.swift
│   │   │   └── AnimatedTransition.swift
│   │   └── DesignSystem/
│   │       ├── Colors.swift
│   │       └── Typography.swift
│   └── MenuBar/
│       └── MenuBarView.swift     # MenuBarExtra 드롭다운 메뉴
│
├── Infrastructure/               # Infrastructure Layer
│   ├── Hotkey/
│   │   └── GlobalHotkeyManager.swift  # Carbon RegisterEventHotKey 래퍼
│   ├── Clipboard/
│   │   └── ClipboardManager.swift     # NSPasteboard 래퍼
│   ├── AutoInjection/
│   │   └── AutoInjectionManager.swift # CGEvent + NSWorkspace 로직
│   └── Permissions/
│       └── AccessibilityChecker.swift # AXIsProcessTrusted() 체크
│
└── Resources/
    ├── Assets.xcassets
    └── Localizable.xcstrings     # 다국어 (한/영)
```

### 3.2 Dependency Injection 전략
- **수동 DI 컨테이너** (`DependencyContainer`) 사용 — SwiftUI `@Environment` 주입
- Protocol 기반 의존성 역전: Domain Layer는 Repository Protocol만 참조
- `@MainActor` ViewModel에 UseCase 프로토콜을 생성자 주입

### 3.3 데이터 흐름
```
User Input (SwiftUI View)
    ↓
ViewModel (@MainActor, @Observable)
    ↓ UseCase Protocol 호출
UseCase (Domain Logic)
    ↓ Repository Protocol 호출
Repository Implementation (Data Layer)
    ↓ URLSession / Keychain / UserDefaults
External Service (OpenRouter / Ollama)
```

---

## 4. API 통신 스펙

### 4.1 OpenRouter API
| 항목 | 상세 |
|------|------|
| Endpoint | `POST https://openrouter.ai/api/v1/chat/completions` |
| 인증 | `Authorization: Bearer <API_KEY>` |
| Content-Type | `application/json` |
| 스트리밍 | `"stream": true` → SSE (`text/event-stream`) |
| 요청 포맷 | OpenAI Chat Completions 호환 (`messages[]`, `model`, `stream`) |
| 응답 포맷 (비스트리밍) | `{"id", "choices": [{"message": {"role","content"}}], "usage": {...}}` |
| 응답 포맷 (스트리밍) | `data: {"choices": [{"delta": {"content": "..."}}]}` → `data: [DONE]` |
| 에러 포맷 | `{"error": {"code": 400, "message": "..."}}` |
| 타임아웃 코멘트 | SSE 스트림에서 `: OPENROUTER PROCESSING` 주기적 전송 (연결 유지용, 무시 가능) |
| 기본 모델 | 사용자 설정 (예: `openai/gpt-4o-mini`, `anthropic/claude-sonnet-4`) |

#### 요청 예시
```json
{
  "model": "openai/gpt-4o-mini",
  "messages": [
    {"role": "system", "content": "You are a prompt engineering assistant..."},
    {"role": "user", "content": "React 카운터 컴포넌트"}
  ],
  "stream": true,
  "temperature": 0.7,
  "max_tokens": 2000
}
```

### 4.2 Ollama Local API
| 항목 | 상세 |
|------|------|
| Endpoint | `POST http://localhost:11434/api/chat` |
| 인증 | 불필요 (로컬) |
| Content-Type | `application/json` |
| 스트리밍 | 기본값 `true` — NDJSON (`application/x-ndjson`) |
| 비스트리밍 | `"stream": false` → 단일 JSON 응답 |
| 요청 포맷 | `{"model": "llama3.2", "messages": [...], "stream": true/false}` |
| 응답 포맷 (스트리밍) | `{"model":"...","message":{"role":"assistant","content":"..."},"done":false}` per line |
| 최종 청크 | `"done": true` + `total_duration`, `eval_count` 등 성능 메트릭 포함 |
| OpenAI 호환 엔드포인트 | `POST http://localhost:11434/v1/chat/completions` (선택적 사용 가능) |
| 모델 목록 | `GET http://localhost:11434/api/tags` |
| 기본 포트 | 11434 (설정 변경 가능) |

### 4.3 공통 에러 처리
| 에러 코드 | 의미 | UI 처리 |
|-----------|------|---------|
| 401 (OpenRouter) | API Key 무효 | 설정창으로 유도 + Key 재입력 안내 |
| 429 | Rate Limit | 재시도 안내 + 백오프 |
| 500/502/503 | 서버 오류 | 일시적 오류 안내 + 재시도 버튼 |
| Connection Refused (Ollama) | Ollama 미실행 | Ollama 실행 안내 토스트 |
| Timeout (120s) | 응답 시간 초과 | 타임아웃 안내 + 재시도 옵션 |
| SSE 파싱 오류 | 스트림 손상 | 수신된 내용까지 표시 + 오류 안내 |

---

## 5. Core Features (핵심 기능)

### 5.1. Floating UI & Global Hotkey

#### Floating Panel
- `NSPanel` subclass (`.nonactivatingPanel` + `.titled` + `.fullSizeContentView`)
- 화면 중앙 상단에 표시 (Spotlight 위치와 유사)
- 배경: `NSVisualEffectView` 블러 효과 (`behindWindow` blending mode)
- 창 크기: 기본 폭 480pt, 높이 자동 조절 (최소 120pt ~ 최대 400pt)
- 투명도 애니메이션: `NSAnimationContext` 기반 fade in/out (0.2초)

#### Global Hotkey
- 기본: `Cmd + Shift + Space` (커스텀 가능)
- 구현: Carbon `RegisterEventHotKey` 래퍼 (HotKey 또는 KeyboardShortcuts 라이브러리)
- **Accessibility 권한 불필요** — Carbon API는 좁은 범위 핫키만 등록

#### UI 구성
```
┌─────────────────────────────────────────────┐
│  🔍 [텍스트 입력창: placeholder 안내]       │
│                                              │
│  [번역]  [프롬프트 확장]  [코드 리뷰]  [⋯]  │
│                                              │
│  ─── AI 처리 중... ─── (로딩 인디케이터)     │
└─────────────────────────────────────────────┘
```

#### 디스미스 제어
| 액션 | 동작 |
|------|------|
| `Esc` 키 | 즉시 닫기 (AI 처리 취소) |
| `Cmd + W` | 즉시 닫기 |
| 창 외부 클릭 | 닫기 (AI 처리 계속 진행, 백그라운드 완료 시 알림) |
| AI 응답 완료 | Auto-Injection 실행 후 자동 닫기 |
| `Enter` | 기본 Skill 실행 또는 선택된 Skill 실행 |

### 5.2. AI 연동 및 Custom Skill 관리

#### Provider 관리
- OpenRouter: API Key 입력 → Keychain 저장
- Ollama: Endpoint URL 입력 (기본 `http://localhost:11434`)
- Provider 전환: 설정창에서 즉시 전환 가능

#### Skill 시스템
```swift
// Skill 데이터 모델
struct Skill: Identifiable, Codable {
    let id: UUID
    var name: String           // "번역", "프롬프트 확장"
    var icon: String           // SF Symbol 이름
    var systemPrompt: String   // AI에게 전달할 시스템 프롬프트
    var isActive: Bool         // UI에 표시 여부
    var sortOrder: Int         // 버튼 정렬 순서
    var isDefault: Bool        // 기본 제공 Skill (삭제 불가)
}
```

#### 기본 제공 Skills
| Skill | System Prompt 목적 |
|-------|-------------------|
| 프롬프트 확장 | 짧은 지시를 상세한 프롬프트로 확장 |
| 번역 (한→영) | 한국어를 영문 개발 프롬프트로 번역 |
| 번역 (영→한) | 영문을 한국어로 번역 |
| 코드 리뷰 | 코드 스니펫 리뷰 요청 프롬프트 생성 |
| 커스텀 | 사용자 정의 |

#### 로딩 UX
- 입력창 하단에 프로그레스 바 표시
- `NSProgressIndicator` (indeterminate) 또는 shimmer 애니메이션
- "AI 처리 중..." 텍스트 + 경과 시간 표시
- 취소 버튼 (`Esc` 또는 X 버튼)

### 5.3. Auto-Injection (자동 입력 및 제어)

#### 권한 흐름
1. 앱 첫 실행 → `AXIsProcessTrusted()` 체크
2. 권한 없음 → 시스템 설정 안내 Alert 표시 (`kAXTrustedCheckOptionPrompt: true`)
3. 권한 승인 대기 → `AXIsProcessTrusted()` 폴링 (1초 간격, 타임아웃 30초)
4. 권한 확보 → 앱 정상 동작

#### Auto-Injection 순서
```
1. NSWorkspace.shared.frontmostApplication → targetApp 저장
2. 사용자 단축키 입력 → FloatingPanel 표시 (targetApp은 이미 보관됨)
3. 사용자 명령 입력 + Skill 선택
4. AI 응답 완료 (스트리밍 수신)
5. NSPasteboard.general → 기존 클립보드 내용 백업
6. AI 응답 텍스트 → NSPasteboard.general 에 복사
7. FloatingPanel 숨김 (fade out 애니메이션)
8. targetApp.activate() → 포커스 복원
9. 짧은 딜레이 (50ms) → CGEvent 로 Cmd+V 전송
10. 100ms 대기 → 클립보드 백업 복원 (옵션)
```

#### 클립보드 보존 정책
- **보존 모드 (기본)**: 기존 클립보드를 백업했다가 Auto-Injection 후 복원
- **미보존 모드**: AI 응답을 클립보드에 남겨둠 (사용자가 수동 붙여넣기 할 수 있도록)
- 설정창에서 토글 가능

#### 엣지 케이스
| 상황 | 처리 |
|------|------|
| 타겟 앱이 종료됨 | 클립보드에만 복사 → 토스트 알림 "앱이 종료되어 클립보드에 복사됨" |
| 접근성 권한 상실 | 설정창으로 유도 + Auto-Injection 비활성화 |
| AI 응답 0바이트 | 에러 토스트 + 패널 유지 |
| Cmd+V 실패 (보안 앱) | 토스트 "자동 입력 실패. 클립보드에 복사됨" |

---

## 6. UI/UX Flow (사용자 경험 흐름)

### 6.1 최초 실행 플로우
```
[앱 실행]
  → [접근성 권한 체크]
    → (권한 없음) → [시스템 설정 안내 Alert] → [권한 승인 대기]
    → (권한 있음) → [메뉴바 아이콘 표시]
      → [API Key 미설정] → [설정창 자동 오픈] → [OpenRouter Key 또는 Ollama URL 입력]
        → [키체인 저장] → [완료 안내] → [백그라운드 대기]
```

### 6.2 일반 사용 플로우
```
1. [작업 중] → 단축키 (Cmd+Shift+Space)
2. [FloatingPanel 표시] → targetApp 추적
3. [텍스트 입력] → Skill 선택 (버튼 클릭 또는 Enter)
4. [AI 처리 중] → 로딩 인디케이터 + 입력 비활성화
5. [AI 응답 완료] → 클립보드 복사 → 패널 숨김
6. [타겟 앱 포커스 복원] → Cmd+V 자동 입력 → 완료
```

### 6.3 설정창 플로우
- 메뉴바 아이콘 클릭 → "Preferences..." 또는 `Cmd + ,`
- 탭 구성: [일반] [API 설정] [Skills 관리] [단축키]
  - **일반**: 클립보드 보존, 기본 Skill, 시작 시 동작
  - **API 설정**: OpenRouter Key, Ollama Endpoint, 기본 모델 선택
  - **Skills 관리**: Skill 추가/수정/삭제/순서 변경, 시스템 프롬프트 편집
  - **단축키**: 전역 단축키 변경 (KeyboardShortcuts.Recorder UI)

---

## 7. Non-Functional Requirements (비기능 요구사항)

### 7.1 Performance
| 항목 | 기준 |
|------|------|
| 단축키 → 패널 표시 | ≤ 100ms |
| 패널 표시 → 키보드 포커스 | ≤ 50ms |
| AI 응답 첫 토큰 표시 | 네트워크 레이턴시 + ≤ 50ms (렌더링) |
| Auto-Injection (붙여넣기) | 응답 완료 후 ≤ 200ms |
| 메모리 사용량 | ≤ 50MB (유휴 상태) |
| 앱 번들 크기 | ≤ 5MB |

### 7.2 Security
| 항목 | 정책 |
|------|------|
| API Key 저장 | Keychain (kSecAttrAccessible: whenUnlockedThisDeviceOnly) |
| 네트워크 | HTTPS 강제 (OpenRouter), HTTP 허용 (Ollama localhost) |
| 입력 데이터 | 로컬 처리, 타사 전송 없음 (AI API 호출 제외) |
| 로깅 | 사용자 입력/응답 로그 저장 안함 (디버그 빌드 제외) |

### 7.3 Accessibility
| 항목 | 정책 |
|------|------|
| VoiceOver | 모든 UI 요소에 접근성 라벨 제공 |
| Dynamic Type | 기본 폰트 크기 준수 |
| 키보드 탐색 | Tab 키로 모든 interactive 요소 탐색 가능 |
| 고대비 모드 | 시스템 설정 준수 |

### 7.4 Reliability
| 항목 | 정책 |
|------|------|
| 네트워크 오류 | 자동 재시도 (최대 2회, exponential backoff) |
| Ollama 미실행 | 연결 실패 감지 → 사용자 안내 |
| 크래시 복구 | 설정/Skill 데이터 손실 방지 (Atomic Write) |
| 백그라운드 동작 | 메뉴바 앱으로 상주, Dock 아이콘 숨김 (`LSUIElement = true`) |

---

## 8. Data Models (데이터 모델)

### 8.1 Core Entities
```swift
// AI Provider
enum AIProvider: String, Codable, CaseIterable {
    case openRouter = "openrouter"
    case ollama = "ollama"
}

// AI 요청 설정
struct AIConfiguration: Codable {
    var provider: AIProvider
    var openRouterAPIKey: String?      // Keychain 저장, 여기엔 참조만
    var openRouterModel: String        // e.g., "openai/gpt-4o-mini"
    var ollamaEndpoint: String         // e.g., "http://localhost:11434"
    var ollamaModel: String            // e.g., "llama3.2"
    var temperature: Double            // 0.0 ~ 2.0, 기본 0.7
    var maxTokens: Int                 // 기본 2000
}

// 프롬프트 요청
struct PromptRequest {
    let userInput: String
    let skill: Skill
    let configuration: AIConfiguration
}

// 프롬프트 결과
struct PromptResult {
    let originalInput: String
    let enrichedOutput: String
    let skillUsed: Skill
    let provider: AIProvider
    let tokenUsage: TokenUsage?
    let latency: TimeInterval
}

struct TokenUsage {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
}
```

### 8.2 App Settings
```swift
struct AppSettings: Codable {
    var globalHotkey: String           // Key representation
    var preserveClipboard: Bool        // 클립보드 보존 모드
    var defaultSkillID: UUID?          // Enter 키 실행 시 사용할 기본 Skill
    var showInDock: Bool               // Dock 아이콘 표시 여부
    var panelOpacity: Double           // 0.0 ~ 1.0, 기본 0.95
}
```

---

## 9. Phased Milestone (개발 단계)

### Phase 1: 기반 시스템 구축 및 UI 기본 형태 (Infrastructure & UI)
**목표**: Floating Panel 표시 및 기본 UI 동작 확인
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| 프로젝트 세팅 | Xcode 프로젝트, SPM 의존성 (HotKey/KeyboardShortcuts) | 빌드 성공 |
| 디렉토리 구조 | Clean Architecture 기반 폴더 구조 | 모든 타겟 폴더 존재 |
| FloatingPanel 구현 | `FloatingPanel` NSPanel subclass | 화면 중앙에 투명 배경 패널 표시 |
| SwiftUI 호스팅 | `NSHostingView`로 SwiftUI 뷰 렌더링 | 텍스트 필드 + 버튼 표시 |
| 디스미스 동작 | Esc, 외부 클릭 시 닫기 | 모든 디스미스 조건 동작 |
| 메뉴바 아이콘 | `MenuBarExtra` 아이콘 표시 | 클릭 시 메뉴 표시 |

### Phase 2: 단축키 및 환경설정 연동 (App Config)
**목표**: 전역 단축키로 패널 호출 + 설정 저장
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| Global Hotkey | Carbon 래퍼 매니저 | Cmd+Shift+Space로 패널 호출 |
| Keychain 연동 | KeychainRepository | API Key 저장/조회/삭제 동작 |
| 설정 UI | Preferences 창 (SwiftUI Settings scene) | 모든 설정 탭 표시 및 저장 |
| Skill 데이터 모델 | Skill entity + LocalSkillRepository | Skill CRUD 동작 |

### Phase 3: AI 통신망 연동 (Domain & Data)
**목표**: OpenRouter/Ollama와 통신하여 응답 수신
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| OpenRouter Repository | API 통신 + SSE 파싱 | 스트리밍 응답 UI에 표시 |
| Ollama Repository | 로컬 API 통신 + NDJSON 파싱 | 스트리밍 응답 UI에 표시 |
| UseCase 구현 | EnrichPrompt, TranslatePrompt | Skill 선택 시 올바른 system prompt 전송 |
| 에러 처리 | 네트워크 에러 → UI 피드백 | 401, 타임아웃, 연결 실패 등 처리 |

### Phase 4: 자동 입력(Auto-Injection) UX 구현 (System Integration)
**목표**: AI 응답을 타겟 앱에 자동 붙여넣기
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| 접근성 권한 | AccessibilityChecker | 권한 체크 + 시스템 설정 유도 |
| App Tracking | NSWorkspace 기반 타겟 추적 | 호출 시점 앱 정확히 보관 |
| 클립보드 관리 | ClipboardManager | 백업 → 복사 → 복원 플로우 |
| CGEvent 자동 입력 | AutoInjectionManager | Cmd+V 이벤트 정상 전송 |
| 통합 테스트 | 전체 플로우 E2E | 입력 → AI → 자동붙여넣기 완료 |

### Phase 5: 고도화 및 안정화 (Polishing)
**목표**: 프로덕션 품질
| 작업 | 산출물 | 완료 기준 |
|------|--------|-----------|
| 에러 엣지 케이스 | 모든 엣지 케이스 처리 | 섹션 5.3 엣지 케이스 전부 커버 |
| 애니메이션 | 패널 fade in/out, 버튼 트랜지션 | 부드러운 60fps 애니메이션 |
| 단위 테스트 | Domain/Data Layer 테스트 | 핵심 로직 80%+ 커버리지 |
| 앱 아이콘/에셋 | 앱 아이콘, 메뉴바 아이콘 | 프로페셔널 디자인 적용 |
| 코드 사이닝 | Developer ID 서명 | Gatekeeper 통과 |

---

## 10. Risks & Mitigations (리스크 및 대응)

| 리스크 | 확률 | 영향 | 대응 방안 |
|--------|------|------|-----------|
| Carbon API deprecated → 향후 macOS에서 제거 | 중간 | 높음 | Apple 대체 API 모니터링. `CGEventTap`으로 마이그레이션 계획 수립 |
| CGEvent 자동 입력이 특정 앱에서 차단 | 중간 | 중간 | 클립보드 복사 폴백 제공. 수동 붙여넣기 안내 |
| OpenRouter API 변경 | 낮음 | 중간 | API 버전 고정 (`/v1/`). 응답 스키마 검증 로직 |
| 접근성 권한 사용자 거부 | 중간 | 높음 | 권한 없이도 클립보드 복사 모드로 동작 가능하도록 설계 |
| Ollama 미설치/미실행 | 높음 | 낮음 | 연결 실패 시 설치 안내 링크 표시 |
| 클립보드 복원 경쟁 조건 | 낮음 | 중간 | NSPasteboard 변경 알림 감지. Atomic 복원 보장 |

---

## 11. Testing Strategy (테스트 전략)

| 레이어 | 테스트 유형 | 도구 | 커버리지 목표 |
|--------|------------|------|--------------|
| Domain | 단위 테스트 | XCTest | 90%+ |
| Data (Repository) | 단위 테스트 (Mock URLSession) | XCTest | 80%+ |
| Presentation (ViewModel) | 단위 테스트 (Mock UseCase) | XCTest | 80%+ |
| Integration | 통합 테스트 (실제 Ollama) | XCTest | 핵심 플로우 |
| UI | 수동 테스트 | - | - |

### 테스트 우선순위
1. **UseCase 단위 테스트**: 프롬프트 생성 로직 검증
2. **Repository 단위 테스트**: API 요청/응답 파싱 검증
3. **ViewModel 단위 테스트**: 상태 변화 및 에러 처리 검증
4. **Auto-Injection 통합 테스트**: 실제 앱 대상 Cmd+V 동작 검증
