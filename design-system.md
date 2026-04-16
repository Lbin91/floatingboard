# FloatingBoard Design System

## 1. Design Philosophy (디자인 철학)

### 1.1 핵심 원칙

**"사라지는 인터페이스 — 사용자는 도구가 아니라 결과에 집중해야 한다."**

FloatingBoard는 사용자의 작업 흐름을 방해하지 않으면서 즉각적인 가치를 제공하는 도구입니다. 인터페이스는 사용자의 의도를 AI에 전달하는 투명한 통로여야 하며, 그 자체로 주목받아서는 안 됩니다.

| 원칙 | 설명 |
|------|------|
| **무게감 없음 (Weightless)** | Floating Panel은 화면 위에 떠 있지만 존재감은 최소화. Spotlight처럼 필요할 때만 나타나고, 임무를 마치면 즉시 사라진다 |
| **즉각성 (Immediacy)** | 모든 인터랙션은 100ms 이내에 반응해야 한다. 지연은 설계 오류다 |
| **네이티브 비행 (Native Flight)** | macOS의 시각 언어를 그대로 승계. 커스텀 UI가 아닌 시스템이 제공하는 재료(blur, vibrancy, SF Symbols)로 조립한다 |
| **맥락 보존 (Context Preservation)** | 사용자가 작업 중이던 환경을 절대 훼손하지 않는다. 클립보드, 포커스, 화면 상태 — 모두 원래대로 복원한다 |
| **정보 밀도 (Density with Clarity)** | 좁은 공간에 충분한 정보를 담되, 시각적 위계로 혼란을 제거한다 |

### 1.2 레퍼런스 앱

| 앱 | 참고 포인트 |
|----|-----------|
| **Spotlight** | Floating Panel의 위치, 크기, 등장/사라짐 애니메이션. 인풋 필드의 시각적 비중 |
| **Raycast** | 다크 테마에서의 Surface 스택 설계. 블러 + 반투명 경계 처리. 키보드 중심 인터랙션 |
| **Alfred** | 커스텀 워크플로우 UI. 심플한 설정 화면 구조 |
| **macOS Control Center** | 팝오버 형태의 설정 UI. SF Symbols 활용. 시스템 블러 매터리얼 |
| **Arc Browser** | Command Bar 인터랙션. 심플한 검색 UI에서 액션으로 확장되는 패턴 |

### 1.3 안티 패턴 (하면 안 되는 것)

| 안티 패턴 | 이유 |
|-----------|------|
| 굵은 외곽선, 강한 그라데이션 | 네이티브 macOS 앱이 아닌 Electron 앱처럼 보임 |
| 팝업 내에 또다른 모달/시트 띄우기 | Floating Panel은 이미 오버레이. 중첩은 인지 부하 급증 |
| 과도한 커스텀 폰트 | 시스템 폰트(SF Pro)를 벗어나면 macOS에 속하지 않는 느낌 |
| 애니메이션 과다 | 기능적 애니메이션(등장/사라짐)만. 장식적 애니메이션 금지 |
| 다크/라이트 외의 커스텀 테마 | 시스템 설정을 따름. 앱 자체 테마는 제공하지 않음 |

---

## 2. Color System (색상 체계)

### 2.1 설계 원칙

FloatingBoard의 색상 체계는 **macOS 시스템 컬러를 기반**으로 하되, AI 어시스턴트로서의 정체성을 나타내는 **Signature Accent**를 하나만 가집니다. 모든 색상은 Dark Mode와 Light Mode 양쪽에서 완벽하게 동작해야 합니다.

**왜 Accent를 하나만?** Raycast, Spotlight, 모든 훌륭한 macOS 유틸리티 앱은 시각적 일관성을 위해 단일 악센트 컬러를 사용합니다. 다색상은 대시보드나 마케팅 페이지에 어울리는 언어입니다. 도구는 단색이다.

### 2.2 Signature Palette

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   Accent (보라빛 인디고)                                │
│   ████████  #6C5CE7                                     │
│                                                         │
│   "AI의 지능적 에너지를 나타내는 인디고-퍼플.           │
│    신뢰감, 지성, 창의성의 교차점."                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Accent Color: Indigo-Purple `#6C5CE7`**

이 색상을 선택한 이유:
- Apple의 `systemIndigo`(#5856D6)보다 약간 밝고 따뜻한 톤 — 작은 UI 요소에서 더 잘 보임
- Apple의 `systemPurple`(#AF52DE)보다 채도가 낮아 부담스럽지 않음
- 다크 배경에서도 라이트 배경에서도 대비가 확실
- "지능적 도구"의 브랜드 이미지와 부합

### 2.3 Full Color Token System

#### Surface Colors (배경 계층)

Surface는 Z축 깊이를 표현합니다. 아래로 갈수록 위로 떠 있는( Elevate) 요소입니다.

| Token | Dark Mode | Light Mode | 용도 |
|-------|-----------|------------|------|
| `surface.root` | `#1C1C1E` | `#FFFFFF` | Floating Panel 기본 배경 |
| `surface.base` | `#242426` | `#F5F5F7` | 입력 필드 배경, 카드 배경 |
| `surface.elevated` | `#2C2C2E` | `#EBEBF0` | 호버 상태, 선택된 Skill 버튼 |
| `surface.sunken` | `#1A1A1C` | `#F0F0F2` | 인셋 영역 (응답 프리뷰 등) |
| `surface.hover` | `rgba(255,255,255,0.06)` | `rgba(0,0,0,0.04)` | 모든 interactive 요소의 호버 |

#### Text Colors (텍스트)

| Token | Dark Mode | Light Mode | 용도 |
|-------|-----------|------------|------|
| `text.primary` | `#FFFFFF` (Opacity 100%) | `#1C1C1E` (Opacity 100%) | 메인 입력 텍스트, Skill 이름 |
| `text.secondary` | `rgba(255,255,255,0.55)` | `rgba(60,60,67,0.60)` | Placeholder, 보조 텍스트 |
| `text.tertiary` | `rgba(255,255,255,0.30)` | `rgba(60,60,67,0.30)` | 힌트 텍스트, 경과 시간 |
| `text.accent` | `#6C5CE7` | `#5A4BD1` | AI 처리 상태, 활성 Skill |
| `text.error` | `#FF453A` | `#D70015` | 에러 메시지 |
| `text.success` | `#30D158` | `#248A3D` | 완료 메시지 |

#### Accent & Status Colors

| Token | Hex (Dark) | Hex (Light) | 용도 |
|-------|------------|-------------|------|
| `accent` | `#6C5CE7` | `#5A4BD1` | Primary actions, 활성 상태, 포커스 링 |
| `accent.subtle` | `rgba(108,92,231,0.15)` | `rgba(90,75,209,0.10)` | Accent 배경 (Skill 버튼 등) |
| `accent.hover` | `#7D6FF0` | `#6C5CE7` | Accent 요소의 호버 상태 |
| `status.loading` | `#6C5CE7` | `#5A4BD1` | 로딩 인디케이터 |
| `status.error` | `#FF453A` | `#D70015` | 에러 상태, 경고 |
| `status.success` | `#30D158` | `#248A3D` | 성공 상태 |
| `status.warning` | `#FFD60A` | `#FF9F0A` | 경고 |

#### Border & Divider Colors

| Token | Dark Mode | Light Mode | 용도 |
|-------|-----------|------------|------|
| `border.default` | `rgba(255,255,255,0.08)` | `rgba(0,0,0,0.06)` | 패널 외곽선, 구분선 |
| `border.subtle` | `rgba(255,255,255,0.04)` | `rgba(0,0,0,0.03)` | 내부 구분선 |
| `border.focus` | `#6C5CE7` | `#5A4BD1` | 포커스 상태 테두리 |
| `border.error` | `#FF453A` | `#D70015` | 에러 상태 테두리 |

#### Glass Material (블러 배경)

Panel 배경에 사용하는 반투명 블러 매터리얼. 단순 hex 색상이 아닌 `NSVisualEffectView` 기반.

| Context | 설정 |
|---------|------|
| Panel 배경 (기본) | `.ultraThinMaterial` + `saturate(180%)` |
| Panel 배경 (고대비) | `.thickMaterial` |
| 내부 오버레이 (로딩 등) | `.thinMaterial` |

```
// Swift 구현 예시
// Panel: behindWindow blending, blur radius ≈ 20px
background: .ultraThinMaterial
opacity: 0.95 (설정에서 조절 가능)
border: 1px solid rgba(255,255,255,0.08) // Dark
border: 1px solid rgba(0,0,0,0.06)       // Light
box-shadow: 0 24px 64px rgba(0,0,0,0.7), 0 8px 16px rgba(0,0,0,0.5) // Dark
box-shadow: 0 16px 48px rgba(0,0,0,0.12), 0 4px 12px rgba(0,0,0,0.08) // Light
```

### 2.4 Dark / Light Mode 비교

```
┌─── DARK MODE ─────────────────────┐  ┌─── LIGHT MODE ────────────────────┐
│                                    │  │                                    │
│  ┌──────────────────────────────┐  │  │  ┌──────────────────────────────┐  │
│  │ ░░░ Glass Blur Background ░░│  │  │  │ ░░░ Glass Blur Background ░░│  │
│  │                              │  │  │  │                              │  │
│  │  🔍 무엇을 도와드릴까요?     │  │  │  │  🔍 무엇을 도와드릴까요?     │  │
│  │  (text.secondary: 55% white) │  │  │  │  (text.secondary: 60% black) │  │
│  │                              │  │  │  │                              │  │
│  │  [번역] [확장] [리뷰] [⋯]  │  │  │  │  [번역] [확장] [리뷰] [⋯]  │  │
│  │  (accent.subtle bg)          │  │  │  │  (accent.subtle bg)          │  │
│  │  (text.primary: 100% white)  │  │  │  │  (text.primary: #1C1C1E)     │  │
│  │                              │  │  │  │                              │  │
│  │  ── 🟣 AI 처리 중... 2.3s ──│  │  │  │  ── 🟣 AI 처리 중... 2.3s ──│  │
│  │  (accent 색상 로딩 바)       │  │  │  │  (accent 색상 로딩 바)       │  │
│  │                              │  │  │  │                              │  │
│  └──────────────────────────────┘  │  │  └──────────────────────────────┘  │
│                                    │  │                                    │
│  배경: #1C1C1E 계층               │  │  배경: #FFFFFF 계층               │
│  글자: White (가변 Opacity)        │  │  글자: Black (가변 Opacity)       │
│  Accent: #6C5CE7                  │  │  Accent: #5A4BD1                  │
│  블러: ultraThinMaterial (0.95)   │  │  블러: ultraThinMaterial (0.95)   │
│  외곽선: white 8%                  │  │  외곽선: black 6%                  │
└────────────────────────────────────┘  └────────────────────────────────────┘
```

### 2.5 접근성 (Accessibility)

모든 색상 조합은 **WCAG 2.1 AA 기준** (일반 텍스트 4.5:1, 대형 텍스트 3:1)을 충족해야 합니다.

| 조합 | Dark Mode 대비율 | Light Mode 대비율 | 기준 충족 |
|------|-----------------|------------------|-----------|
| `text.primary` on `surface.root` | 15.4:1 | 15.4:1 | AA ✅ AAA ✅ |
| `text.secondary` on `surface.root` | 5.2:1 | 5.8:1 | AA ✅ |
| `accent` on `surface.root` | 5.9:1 | 5.4:1 | AA ✅ |
| `text.error` on `surface.root` | 5.1:1 | 5.7:1 | AA ✅ |
| `text.primary` on `accent` | 3.8:1 | 4.1:1 | AA (대형) ✅ |

> **주의**: `text.tertiary`는 보조 정보에만 사용. interactive 요소의 상태 전달에는 사용 금지.

---

## 3. Typography (타이포그래피)

### 3.1 폰트 패밀리

**SF Pro** (시스템 폰트)만 사용. 커스텀 폰트 로드하지 않음.

| 용도 | 폰트 | 비고 |
|------|------|------|
| UI 텍스트 | **SF Pro Text** | ≤ 20pt. 텍스트 입력, 버튼 라벨, 메시지 |
| 디스플레이 | **SF Pro Display** | > 20pt. 설정창 헤더 (필요 시) |
| 코드/모노스페이스 | **SF Mono** | 프롬프트 프리뷰, 응답 내 코드 블록 |
| 아이콘 | **SF Symbols** | 모든 아이콘. 커스텀 에셋 아이콘 사용하지 않음 |

### 3.2 Type Scale

Floating Panel의 좁은 공간에서 명확한 위계를 만들기 위한 타입 스케일입니다.

| Token | Size | Weight | Tracking | Line Height | 용도 |
|-------|------|--------|----------|-------------|------|
| `display` | 17pt | `.bold` | -0.4pt | 22pt | 설정창 섹션 타이틀 |
| `title` | 15pt | `.semibold` | -0.2pt | 20pt | Floating Panel 타이틀 (사용 안 할 수도 있음) |
| `body` | 14pt | `.regular` | 0pt | 18pt | 메인 텍스트 입력, 일반 텍스트 |
| `body.mono` | 13pt | `.regular` | 0pt | 18pt | 프롬프트 프리뷰 (SF Mono) |
| `caption` | 12pt | `.regular` | 0.1pt | 16pt | Skill 버튼 라벨, 보조 정보 |
| `caption.bold` | 12pt | `.medium` | 0.1pt | 16pt | Skill 버튼 라벨 (활성 상태) |
| `micro` | 10pt | `.regular` | 0.2pt | 14pt | 경과 시간, 토큰 카운트 |

### 3.3 텍스트 사용 원칙

| 원칙 | 설명 |
|------|------|
| **Weight로 위계 구분** | Size가 아닌 Weight(Regular vs Semibold)로 중요도 구분 |
| **최대 2 레벨** | Floating Panel 내 텍스트 위계는 최대 2단계. Primary + Secondary |
| **Truncation 금지** | 텍스트가 공간을 초과하면 `...` 대신 패널 높이 자동 조절 |
| **Placeholder는 행동 유도** | "텍스트를 입력하세요" (X) → "무엇을 도와드릴까요?" (O) |

---

## 4. Spacing & Layout (간격과 레이아웃)

### 4.1 Spacing Scale

4pt 그리드 기반. 2의 배수만 사용.

| Token | Value | 용도 |
|-------|-------|------|
| `xxs` | 4pt | 아이콘과 텍스트 사이 간격 |
| `xs` | 8pt | 같은 그룹 내 요소 간격 |
| `sm` | 12pt | Skill 버튼 간 간격 |
| `md` | 16pt | 섹션 간 구분 (입력창과 버튼 영역) |
| `lg` | 20pt | 패널 내 콘텐츠 좌우 패딩 |
| `xl` | 24pt | 패널 상하 패딩 |
| `2xl` | 32pt | 설정창 섹션 간격 |

### 4.2 Floating Panel 레이아웃

```
화면 상단에서 약 20% 위치 (Spotlight 위치)

←──────────── 480pt (기본 폭) ────────────→

┌─────────────────────────────────────────────┐  ↑
│                                              │  xl (24pt)
│  🔍  무엇을 도와드릴까요?                    │  ← 입력 필드: 높이 40pt
│                                              │
│──────────────────────────────────────────────│  md (16pt)
│                                              │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐       │  xs (8pt) 내부
│  │ 번역 │ │ 확장 │ │ 리뷰 │ │  ⋯  │       │  ← Skill 버튼: 높이 32pt
│  └──────┘ └──────┘ └──────┘ └──────┘       │
│                                              │
│──────────────────────────────────────────────│  sm (12pt)
│  ─── AI 처리 중... 2.3s ───                 │  ← 상태 영역: 높이 24pt (처리 중에만)
│                                              │  lg (20pt)
└──────────────────────────────────────────────┘

총 높이:
  - 대기 상태: ≈ 132pt (패딩 + 입력 + 버튼)
  - 처리 중: ≈ 168pt (+ 상태 영역)
  - 프리뷰 표시: 최대 400pt (스크롤)
```

### 4.3 Corner Radius

| 요소 | Radius | Style |
|------|--------|-------|
| Floating Panel 외곽 | 14pt | `.continuous` |
| 입력 필드 | 10pt | `.continuous` |
| Skill 버튼 | 8pt | `.continuous` |
| 토스트 알림 | 10pt | `.continuous` |
| 설정창 탭 | 시스템 기본 | — |

> **모든 Corner Radius는 `.continuous` 스타일**. 원형(circular)이 아닌 연속 곡선. macOS 네이티브 앱의 핵심 디테일.

---

## 5. Components (UI 컴포넌트)

### 5.1 Floating Panel

```
┌─── Floating Panel ──────────────────────────────────────────┐
│                                                              │
│  ╭────────────────────────────────────────────────────────╮  │
│  │  🔍  무엇을 도와드릴까요?                               │  │  ← TextField
│  │     (placeholder: text.secondary)                       │  │     배경: surface.base
│  │     (입력 텍스트: text.primary)                         │  │     테두리: border.default
│  ╰────────────────────────────────────────────────────────╯  │     포커스: border.focus (accent)
│                                                              │
│  ╭──────╮  ╭──────╮  ╭──────╮  ╭──────╮                    │
│  │  번역  │  │  확장  │  │  리뷰  │  │  ⋯   │                    │
│  ╰──────╯  ╰──────╯  ╰──────╯  ╰──────╯                    │
│                                                              │
│  ──── 🟣 AI 처리 중... 2.3s ────                            │  ← StatusBar (조건부)
│                                                              │
└──────────────────────────────────────────────────────────────┘
│                                                              │
│  배경: Glass (ultraThinMaterial + 0.95 opacity)             │
│  외곽선: border.default (1pt)                                │
│  그림자: Heavy (Dark) / Medium (Light)                       │
│  등장: fade-in 0.2s + scale(0.97→1.0)                       │
│  사라짐: fade-out 0.15s + scale(1.0→0.97)                   │
```

**Panel 상태 변화:**

| 상태 | 입력 필드 | Skill 버튼 | StatusBar | Panel 높이 |
|------|-----------|-----------|-----------|-----------|
| **초기** | placeholder + 포커스 | 모두 활성 | 숨김 | 최소 (132pt) |
| **입력 중** | 텍스트 표시 | 모두 활성 | 숨김 | 최소 |
| **처리 중** | 비활성화 (dimmed) | 비활성화 | 로딩 바 + 시간 | +36pt |
| **에러** | 에러 테두리 | 재시도 버튼 활성 | 에러 메시지 | +36pt |
| **완료** | 결과 텍스트 (0.5초) | 숨김 | "완료 ✓" (0.5초) | 최소 → 닫힘 |

### 5.2 Skill Button

```
기본 (Default)                활성 (Active)                 호버 (Hover)
╭──────────────╮              ╭──────────────╮              ╭──────────────╮
│  🌐  번역     │              │  🌐  번역     │              │  🌐  번역     │
│  (text.primary)│              │  (accent)     │              │  (text.primary)│
╰──────────────╯              ╰──────────────╯              ╰──────────────╯
배경: transparent              배경: accent.subtle            배경: surface.hover
테두리: border.default         테두리: accent                 테두리: border.default
아이콘: text.secondary         아이콘: accent                 아이콘: text.secondary

크기: 고정 높이 32pt, 좌우 패딩 12pt
폰트: caption (12pt, regular → active: medium)
SF Symbol: 14pt, regular weight
```

**Skill 버튼 인터랙션:**

| 이벤트 | 동작 |
|--------|------|
| Hover | 배경 `surface.hover`로 전환 (0.1s) |
| Click | → 활성 상태로 전환 + AI 처리 시작 |
| Keyboard (Tab) | Focus ring 표시 (`border.focus`) |
| Disabled (처리 중) | Opacity 0.4, 클릭 무시 |
| ⋯ (더보기) | 팝오버 메뉴: 커스텀 Skill 목록 |

### 5.3 Loading Indicator

```
처리 중 (Processing)
────────────────────────────────────────
  🔵 ──────────────────── 2.3s

  좌: SF Symbol("sparkles") accent 컬러
  중: Progress bar (indeterminate → determinate)
      배경: surface.base
      채움: accent (#6C5CE7)
      높이: 3pt, Corner radius: 1.5pt
  우: 경과 시간 (micro, text.tertiary)
  우측 끝: 취소 버튼 (SF Symbol "xmark.circle")

  애니메이션: Shimmer 효과 (accent → accent.hover → accent, 1.5s loop)
```

### 5.4 Toast Notification (상태 알림)

```
╭──────────────────────────────────────────────╮
│  ✓  클립보드에 복사됨                         │
╰──────────────────────────────────────────────╯

위치: 화면 하단 중앙 (화면 하단에서 60pt 위)
크기: 고정 높이 40pt, 텍스트에 맞춰 폭 자동 조절
배경: surface.elevated (solid, 투명 없음)
테두리: border.default
그림자: Medium
등장: slide-up + fade-in (0.25s)
사라짐: fade-out (0.2s, 3초 후 자동)
```

**Toast 종류:**

| 유형 | 아이콘 | 색상 | 메시지 예시 |
|------|--------|------|------------|
| 성공 | `checkmark.circle.fill` | `status.success` | "클립보드에 복사됨" |
| 에러 | `exclamationmark.triangle.fill` | `status.error` | "연결 실패. 다시 시도해주세요." |
| 경고 | `exclamationmark.circle.fill` | `status.warning` | "Ollama가 실행 중이 아닙니다" |
| 정보 | `info.circle.fill` | `accent` | "설정창을 엽니다..." |

### 5.5 Preferences Window (설정창)

macOS 표준 `Settings` scene. SwiftUI `TabView` 기반.

```
╭────────────────────────────────────────────────────────────────╮
│                                                                │
│  [ 일반 ]  [ API 설정 ]  [ Skills ]  [ 단축키 ]               │  ← Tab bar
│                                                                │
│────────────────────────────────────────────────────────────────│
│                                                                │
│  클립보드 보존                                                 │
│  ┌────────────────────────────────┐                           │
│  │  ● 활성화                      │  ← Toggle                │
│  └────────────────────────────────┘                           │
│                                                                │
│  기본 Skill                                                    │
│  ┌────────────────────────────────┐                           │
│  │  프롬프트 확장              ▾  │  ← Picker                │
│  └────────────────────────────────┘                           │
│                                                                │
│  패널 투명도                                                   │
│  ──────●─────────────── 95%                                   │  ← Slider
│                                                                │
└────────────────────────────────────────────────────────────────┘

설정창은 시스템 표준 SwiftUI Form 사용.
커스텀 스타일링 최소화.
시스템 Dark/Light Mode 자동 따름.
```

**Skills 관리 탭:**

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  ┌─ Skills ──────────────────────────────────── ╭───────────╮ │
│  │                                               │  + 추가    │ │
│  │  ≡  🌐  번역 (한→영)                    [_ON] │  - 삭제    │ │
│  │  ≡  ✨  프롬프트 확장                   [_ON] │  ✎ 편집    │ │
│  │  ≡  🔍  코드 리뷰                       [ON_] │            │ │
│  │  ≡  🌐  번역 (영→한)                    [ON_] │            │ │
│  │                                               ╰───────────╯ │
│  │  (≡: 드래그로 순서 변경)                                   │
│  └─────────────────────────────────────────────────────────────│
│                                                                │
│  ── Skill 편집 ─────────────────────────────────────────────  │
│                                                                │
│  이름: [프롬프트 확장                                 ]        │
│  아이콘: [SF Symbol Picker...]                                │
│                                                                │
│  시스템 프롬프트:                                             │
│  ┌────────────────────────────────────────────────┐           │
│  │  당신은 프롬프트 엔지니어링 전문가입니다.       │           │
│  │  사용자의 짧은 지시를 상세하고 명확한            │           │
│  │  프롬프트로 확장하세요...                         │           │
│  └────────────────────────────────────────────────┘           │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### 5.6 MenuBar Icon & Menu

```
메뉴바 아이콘:
  기본: SF Symbol "sparkles" (16×16, template image)
  처리 중: SF Symbol "sparkles" + 점선 애니메이션 (회전)

┌─────────────────────┐
│  FloatingBoard       │  ← 앱 이름 (bold)
│─────────────────────│
│  패널 열기    ⌘⇧Space│  ← 단축키 표시
│  설정...         ⌘,  │
│─────────────────────│
│  최근 사용한 Skill   │
│    › 프롬프트 확장   │
│    › 번역 (한→영)    │
│─────────────────────│
│  FloatingBoard 정보  │
│  종료             ⌘Q │
└─────────────────────┘
```

---

## 6. Motion & Animation (모션과 애니메이션)

### 6.1 원칙

| 원칙 | 설명 |
|------|------|
| **기능적 모션만** | 상태 변화를 설명하는 애니메이션만. 장식적 모션 금지 |
| **200ms 룰** | 모든 애니메이션은 150~250ms. 느리면 인지적 지연, 빠르면 깜빡임 |
| **Easing: Ease-Out** | 등장은 ease-out. 사라짐도 ease-out. Bounce, elastic 금지 |
| **의미 있는 변화** | 크기, 투명도, 위치 — 한 번에 하나만. 동시 변화는 최대 2개 |

### 6.2 Animation Catalog

| 요소 | 등장 | 사라짐 | Curve | Duration |
|------|------|--------|-------|----------|
| Floating Panel | fade-in + scale(0.97→1.0) | fade-out + scale(1.0→0.97) | `.easeOut` | 200ms / 150ms |
| Skill 버튼 활성 | 배경색 전환 | — | `.easeInOut` | 100ms |
| Skill 버튼 호버 | 배경색 전환 | — | `.easeInOut` | 80ms |
| 로딩 바 | 좌→우 fill | — | `.linear` | indeterminate loop 1.5s |
| 토스트 | slide-up + fade-in | fade-out | `.easeOut` | 250ms / 200ms |
| 에러 흔들림 | ← 4pt → 4pt → 0 | — | `.easeInOut` | 300ms (3회) |
| 프리뷰 확장 | 높이 증가 | 높이 감소 | `.spring(duration: 0.3, bounce: 0.1)` | 300ms |

### 6.3 Spring Parameters

SwiftUI `.spring()` 사용 시:

| 용도 | Duration | Bounce | Blend |
|------|----------|--------|-------|
| Panel 등장 | 0.25s | 0 | 0.2 |
| 콘텐츠 높이 변화 | 0.3s | 0.1 | 0.2 |
| 버튼 피드백 | 0.15s | 0 | 0.2 |

---

## 7. Iconography (아이콘)

### 7.1 원칙

- **SF Symbols만 사용**. 커스텀 에셋 아이콘 제작하지 않음
- 항상 **Semantic Color** 적용 (`foregroundStyle`), 절대 hex 직접 지정하지 않음
- Regular weight 기본. Small size는 14pt, Normal은 16pt

### 7.2 Icon Mapping

| 요소 | SF Symbol | Weight | Size |
|------|-----------|--------|------|
| 입력 필드 (검색) | `magnifyingglass` | regular | 14pt |
| Skill: 번역 | `globe` | regular | 14pt |
| Skill: 프롬프트 확장 | `sparkles` | regular | 14pt |
| Skill: 코드 리뷰 | `chevron.left.forwardslash.chevron.right` | regular | 14pt |
| Skill: 더보기 | `ellipsis` | regular | 14pt |
| 로딩 상태 | `sparkles` (pulsing) | regular | 12pt |
| 에러 | `exclamationmark.triangle.fill` | regular | 14pt |
| 성공 | `checkmark.circle.fill` | regular | 14pt |
| 취소 | `xmark.circle` | regular | 12pt |
| 메뉴바 아이콘 | `sparkles` | medium | 16pt (template) |
| 설정: API Key | `key.fill` | regular | — |
| 설정: Ollama | `server.rack` | regular | — |
| 설정: 단축키 | `keyboard` | regular | — |
| 순서 변경 (드래그) | `line.3.horizontal` | regular | 12pt |
| 토글 ON | `checkmark` | semibold | 12pt |

---

## 8. Sound & Haptics (사운드)

### 8.1 사운드 정책

**기본적으로 사운드 없음.** macOS 유틸리티 앱에서 소리는 방해가 됩니다.

| 이벤트 | 사운드 | 비고 |
|--------|--------|------|
| Panel 등장 | 없음 | 시각적 애니메이션으로 충분 |
| AI 처리 완료 | 없음 | Panel 사라짐으로 충분 |
| 에러 | 없음 | 시각적 에러 표시로 충분 |

> 예외: 향후 사용자 피드백에 따라 완료 시 미세한 시스템 사운드 옵션 추가 고려

---

## 9. Design Tokens — Swift 구현 가이드

### 9.1 Color Token 정의

```swift
import SwiftUI

extension Color {
    // MARK: - Surface
    static let surfaceRoot = Color(nsColor: .windowBackgroundColor)
    static let surfaceBase = Color(nsColor: .controlBackgroundColor)
    static let surfaceElevated = Color(nsColor: .controlColor)

    // MARK: - Text
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(nsColor: .tertiaryLabelColor)

    // MARK: - Accent (FloatingBoard Signature)
    static let accent = Color(
        light: Color(red: 0.353, green: 0.294, blue: 0.820),  // #5A4BD1
        dark: Color(red: 0.424, green: 0.361, blue: 0.906)     // #6C5CE7
    )
    static let accentSubtle = Color.accent.opacity(0.12)
    static let accentHover = Color(
        light: Color(red: 0.424, green: 0.361, blue: 0.906),  // #6C5CE7
        dark: Color(red: 0.490, green: 0.435, blue: 0.941)     // #7D6FF0
    )

    // MARK: - Status
    static let statusError = Color(nsColor: .systemRed)
    static let statusSuccess = Color(nsColor: .systemGreen)
    static let statusWarning = Color(nsColor: .systemYellow)

    // MARK: - Border
    static let borderDefault = Color.primary.opacity(0.08)
    static let borderSubtle = Color.primary.opacity(0.04)
    static let borderFocus = Color.accent
}

// Adaptive Color Helper
extension Color {
    init(light: Color, dark: Color) {
        self.init(UITraitCollection.current.userInterfaceStyle == .dark
            ? dark : light)
    }
}
```

> **참고**: macOS에서는 `NSColor` semantic colors를 최대한 활용. 시스템 색상은 Dark/Light 전환, 고대비 모드를 자동으로 처리합니다.

### 9.2 Spacing Token

```swift
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}
```

### 9.3 Corner Radius Token

```swift
enum CornerRadius {
    static let panel: CGFloat = 14
    static let textField: CGFloat = 10
    static let button: CGFloat = 8
    static let toast: CGFloat = 10
}
```

### 9.4 Typography Token

```swift
enum Typography {
    static let display = Font.system(size: 17, weight: .bold)
    static let title = Font.system(size: 15, weight: .semibold)
    static let body = Font.system(size: 14, weight: .regular)
    static let bodyMono = Font.system(size: 13, weight: .regular, design: .monospaced)
    static let caption = Font.system(size: 12, weight: .regular)
    static let captionBold = Font.system(size: 12, weight: .medium)
    static let micro = Font.system(size: 10, weight: .regular)
}
```

---

## 10. Design QA Checklist (디자인 품질 체크리스트)

모든 UI 구현完成后 다음 체크리스트로 검증합니다.

### 시각적 일관성
- [ ] Dark Mode / Light Mode 양쪽에서 정상 표시
- [ ] 시스템 Accent Color 변경 시 UI 깨짐 없음
- [ ] 모든 Corner Radius `.continuous` 적용
- [ ] SF Symbols가 Semantic Color로 렌더링
- [ ] Glass 배경이 `.ultraThinMaterial` 기반

### 접근성
- [ ] VoiceOver로 모든 요소 탐색 가능
- [ ] 텍스트 대비율 WCAG AA 충족
- [ ] 키보드만으로 전체 플로우 수행 가능
- [ ] Dynamic Type에서 레이아웃 깨짐 없음

### 모션
- [ ] 모든 애니메이션 150~250ms 범위
- [ ] Reduce Motion 설정 시 애니메이션 비활성화
- [ ] Bounce / Elastic 애니메이션 미사용

### 성능
- [ ] Panel 등장 ≤ 100ms
- [ ] 애니메이션 60fps 유지
- [ ] 블러 효과 GPU 가동으로 인한 과도한 팬 소음 없음
