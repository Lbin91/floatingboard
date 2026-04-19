# FloatingBoard Design System

## 1. Design Philosophy (디자인 철학)

### 1.1 핵심 원칙

**"좋은 프롬프트는 한 번에 떠오르는 문장이 아니라, 잘 쪼개진 선택의 결과다."**

FloatingBoard의 UI는 사용자가 잘 쓰기 어려운 프롬프트를 대신 써주는 척하는 도구가 아닙니다. 대신 사용자가 자신의 의도를 더 세밀하게 고르게 만들고, 그 선택을 마찰 없이 조합하도록 돕는 **구조화 인터페이스**입니다.

| 원칙 | 설명 |
|------|------|
| **사고 분해 (Decomposition First)** | 자유 입력보다 먼저 상황과 작업 유형을 고르게 해 생각을 좁힌다 |
| **집중 유지 (Single Focus)** | MVP에서는 한 번에 하나의 소주제만 다루게 해 프롬프트를 날카롭게 만든다 |
| **클릭 기반 수집 (Curated Collection)** | 키워드 선택은 회원가입 관심사 선택처럼 가볍고 빠르게 느껴져야 한다 |
| **편집 가능한 결과 (Editable Output)** | 자동 조립된 프롬프트가 끝이 아니라, 사용자가 바로 수정 가능한 초안이어야 한다 |
| **맥락 존중 (Context Matters)** | 선택된 키워드, 초안, 문서 자산이 어떻게 합쳐지는지 항상 보여준다 |
| **네이티브 절제 (Native Restraint)** | macOS 유틸리티답게 시각적 과장을 줄이고, 구조와 반응성으로 품질을 만든다 |

### 1.2 레퍼런스 앱

| 앱 | 참고 포인트 |
|----|-----------|
| **Spotlight** | 빠른 호출감, 화면 위 존재감 최소화 |
| **Raycast** | 커맨드 패널 밀도, 키보드 중심 플로우 |
| **Linear** | 복잡한 상태를 간결한 토큰 UI로 보여주는 방법 |
| **Notion AI** | 초안과 보조 액션이 같은 작업면에 공존하는 방식 |
| **Arc Command Bar** | 액션 전환과 선택 기반 인터랙션의 경쾌함 |

### 1.3 안티 패턴

| 안티 패턴 | 이유 |
|-----------|------|
| 처음부터 큰 텍스트 영역만 보여주기 | 사용자가 다시 막막한 자유 입력 상태로 돌아감 |
| 키워드를 너무 많이 한 화면에 쏟아내기 | 선택 피로가 생기고 사고 분해가 아니라 분산이 된다 |
| 단계마다 별도 모달/시트 열기 | 빌더가 끊기고 흐름이 깨진다 |
| 프롬프트 미리보기를 숨기기 | 사용자가 앱이 무엇을 만들고 있는지 이해하지 못한다 |
| 지나친 브랜딩, 장식용 애니메이션 | 유틸리티 도구의 신뢰감과 속도를 해친다 |

---

## 2. Color System (색상 체계)

### 2.1 설계 원칙

색상은 제품의 기능을 강조해야지, 테마를 과장해서는 안 됩니다. FloatingBoard는 macOS 네이티브 기반의 절제된 팔레트를 유지하되, 선택과 포커스를 선명하게 드러내는 단일 Accent를 사용합니다.

### 2.2 Signature Palette

**Accent Color: Indigo-Purple `#6C5CE7`**

이 색상이 하는 일:
- 현재 단계와 선택 상태를 분명히 보여준다
- 프롬프트 조립의 "활성화된 사고" 느낌을 준다
- Light/Dark 양쪽에서 작은 칩, 포커스 링, 주요 액션에 안정적으로 동작한다

### 2.3 Full Color Token System

#### Surface Colors

| Token | Dark Mode | Light Mode | 용도 |
|-------|-----------|------------|------|
| `surface.root` | `#1C1C1E` | `#FFFFFF` | 패널 기본 배경 |
| `surface.base` | `#242426` | `#F5F5F7` | 입력 영역, 미리보기 카드 |
| `surface.elevated` | `#2C2C2E` | `#EBEBF0` | 선택된 그룹, hover 상태 |
| `surface.sunken` | `#1A1A1C` | `#F0F0F2` | 비활성 영역, secondary preview |
| `surface.hover` | `rgba(255,255,255,0.06)` | `rgba(0,0,0,0.04)` | interactive hover |

#### Text Colors

| Token | Dark Mode | Light Mode | 용도 |
|-------|-----------|------------|------|
| `text.primary` | `#FFFFFF` | `#1C1C1E` | 메인 텍스트 |
| `text.secondary` | `rgba(255,255,255,0.60)` | `rgba(60,60,67,0.60)` | 보조 텍스트 |
| `text.tertiary` | `rgba(255,255,255,0.35)` | `rgba(60,60,67,0.35)` | 힌트, 카운터 |
| `text.accent` | `#6C5CE7` | `#5A4BD1` | 선택 상태, 단계 라벨 |
| `text.error` | `#FF453A` | `#D70015` | 에러 |
| `text.success` | `#30D158` | `#248A3D` | 성공 |

#### Accent & Status Colors

| Token | Hex (Dark) | Hex (Light) | 용도 |
|-------|------------|-------------|------|
| `accent` | `#6C5CE7` | `#5A4BD1` | 주요 액션, 활성 칩, 포커스 |
| `accent.subtle` | `rgba(108,92,231,0.15)` | `rgba(90,75,209,0.10)` | 선택된 칩 배경 |
| `accent.hover` | `#7D6FF0` | `#6C5CE7` | hover 강화 |
| `status.loading` | `#6C5CE7` | `#5A4BD1` | LLM 처리, 번역 진행 |
| `status.error` | `#FF453A` | `#D70015` | 오류 상태 |
| `status.success` | `#30D158` | `#248A3D` | 복사 완료 등 |
| `status.warning` | `#FFD60A` | `#FF9F0A` | 길이 초과, 문서 누락 경고 |

#### Border & Divider Colors

| Token | Dark Mode | Light Mode | 용도 |
|-------|-----------|------------|------|
| `border.default` | `rgba(255,255,255,0.08)` | `rgba(0,0,0,0.06)` | 패널 외곽선, 카드 경계 |
| `border.subtle` | `rgba(255,255,255,0.04)` | `rgba(0,0,0,0.03)` | 내부 구분선 |
| `border.focus` | `#6C5CE7` | `#5A4BD1` | 포커스 링 |
| `border.error` | `#FF453A` | `#D70015` | 에러 테두리 |

### 2.4 상태별 컬러 사용법

| 상태 | 배경 | 텍스트 | 테두리 |
|------|------|--------|--------|
| 기본 | `surface.base` | `text.primary` | `border.default` |
| hover | `surface.hover` | `text.primary` | `border.default` |
| selected | `accent.subtle` | `text.accent` | `accent` |
| disabled | `surface.sunken` | `text.tertiary` | `border.subtle` |
| error | `surface.base` | `text.error` | `border.error` |

### 2.5 접근성

모든 선택 가능한 칩과 버튼은 색상만으로 상태를 전달해서는 안 됩니다. 활성 상태는 다음을 함께 사용합니다.

- 배경색 변화
- 텍스트 색 변화
- 테두리 강조
- 체크 아이콘 또는 상태 점

### 2.6 Glass Material Strategy

패널이 MVP 기준 최대 `560pt x 620pt`까지 커질 수 있으므로, 작은 입력창 수준의 블러 기준만으로는 읽기성을 유지하기 어렵습니다. 큰 패널에서는 배경 blur보다 내부 surface 계층이 더 중요합니다.

| Context | 설정 |
|---------|------|
| Panel 배경 (기본) | `.ultraThinMaterial` + opacity `0.94` |
| Panel 배경 (긴 프리뷰 활성) | `.thinMaterial` + opacity `0.96` |
| Preview/Card 배경 | `surface.base` 기반의 준불투명 solid |
| Divider/Group 배경 | `surface.elevated` |

추가 원칙:
- 프롬프트 미리보기는 블러 위에 직접 올리지 않고, 별도 card surface 위에 배치
- 긴 프리뷰 상태에서는 blur보다 내부 card 대비를 우선 조정
- 배경이 복잡할수록 opacity를 올리기보다 surface 계층을 한 번 더 추가
- glass 효과의 목적은 장식이 아니라 집중 유지

---

## 3. Typography (타이포그래피)

### 3.1 폰트 패밀리

**SF Pro**만 사용합니다.

| 용도 | 폰트 | 비고 |
|------|------|------|
| UI 텍스트 | **SF Pro Text** | 선택 칩, 설명, 입력 |
| 제목 | **SF Pro Display** | 섹션 헤더 |
| 모노스페이스 | **SF Mono** | 프롬프트 미리보기, 길이 정보 |
| 아이콘 | **SF Symbols** | 시맨틱 아이콘 전용 |

### 3.2 Type Scale

| Token | Size | Weight | Line Height | 용도 |
|-------|------|--------|-------------|------|
| `display` | 18pt | `.bold` | 24pt | 패널 헤더 |
| `title` | 15pt | `.semibold` | 20pt | 섹션 제목 |
| `body` | 14pt | `.regular` | 20pt | 입력, 일반 텍스트 |
| `body.mono` | 13pt | `.regular` | 18pt | 프롬프트 프리뷰 |
| `caption` | 12pt | `.regular` | 16pt | 키워드 칩, 보조 설명 |
| `caption.bold` | 12pt | `.medium` | 16pt | 선택된 칩 |
| `micro` | 10pt | `.regular` | 14pt | 상태, 길이 카운터 |

### 3.3 텍스트 사용 원칙

| 원칙 | 설명 |
|------|------|
| **한 화면 최대 3단계 위계** | Header / Body / Meta 정도로 제한 |
| **설명은 짧게, 결과는 길게** | 안내 문장은 짧고, 프롬프트 프리뷰는 충분히 보여준다 |
| **Placeholder는 사고 유도형** | "무엇을 만들고 싶은가?"처럼 행동을 유도 |
| **칩 라벨은 명사형 우선** | 빠르게 훑기 쉽도록 짧고 일관되게 유지 |

---

## 4. Spacing & Layout (간격과 레이아웃)

### 4.1 Spacing Scale

| Token | Value | 용도 |
|-------|-------|------|
| `xxs` | 4pt | 아이콘-텍스트 사이 |
| `xs` | 8pt | 같은 그룹 내부 |
| `sm` | 12pt | 칩 간 간격 |
| `md` | 16pt | 섹션 간 기본 간격 |
| `lg` | 20pt | 패널 가로 패딩 |
| `xl` | 24pt | 패널 세로 패딩 |
| `2xl` | 32pt | 큰 섹션 간격 |

### 4.2 Floating Panel 레이아웃

```
화면 상단에서 약 18~20% 위치

←──────────────── 560pt 기본 폭 ────────────────→

┌──────────────────────────────────────────────────────┐
│ Prompt Builder                                       │
│ Coding / 오류 개선                                   │
│                                                      │
│ [코딩]                                               │  ← 대주제
│                                                      │
│ [최초 기획] [기획 수정] [구현 작업] [오류 개선] ... │  ← 소주제
│                                                      │
│ 작업 대상                                            │
│ [Swift] [API] [UI] [테스트] ...                     │
│                                                      │
│ 제약조건                                             │
│ [최소 수정] [새 의존성 금지] [기존 스타일 유지]     │
│                                                      │
│ 초안 입력                                            │
│ ┌──────────────────────────────────────────────────┐ │
│ │ SwiftUI 설정 화면의 API 키 저장 구조를...       │ │
│ └──────────────────────────────────────────────────┘ │
│                                                      │
│ Prompt Preview                                       │
│ ┌──────────────────────────────────────────────────┐ │
│ │ Current Situation: ...                           │ │
│ │ Task Type: ...                                   │ │
│ │ Constraints: ...                                 │ │
│ └──────────────────────────────────────────────────┘ │
│                                                      │
│ [다듬기] [영문 번역] [복사]                          │
└──────────────────────────────────────────────────────┘
```

### 4.3 높이 원칙

| 상태 | 높이 |
|------|------|
| 초기 최소 상태 | 약 220pt |
| 소주제 + 키워드 노출 | 320~420pt |
| 프롬프트 프리뷰 확장 | 최대 620pt |

> 빌더는 한 화면에서 끝나야 한다. 스크롤은 허용하되, 단계가 시각적으로 끊기지 않아야 한다.

### 4.4 키워드 노출 밀도

한 소주제 안에서 보이는 키워드는 "가능한 모든 것"이 아니라, "지금 바로 도움이 되는 것"이어야 합니다.

| 규칙 | 기준 |
|------|------|
| 초기 총 노출 키워드 수 | 8~12개 |
| 초기 노출 그룹 수 | 최대 3개 |
| 그룹당 기본 노출 키워드 수 | 2~4개 |
| 저빈도 키워드 | `더 보기` 또는 후속 확장 인터랙션으로 이동 |

레이아웃 원칙:
- 첫 화면은 스캔 가능해야 하고, 칩 벽처럼 보이면 실패
- 추천 키워드는 각 그룹 첫 줄에 배치
- `작업 대상`, `제약조건`, `출력 방식`처럼 의미가 즉시 전달되는 그룹을 우선 노출

### 4.5 Corner Radius

| 요소 | Radius | Style |
|------|--------|-------|
| Floating Panel 외곽 | 14pt | `.continuous` |
| 입력 필드 | 10pt | `.continuous` |
| 선택 칩 | 8pt | `.continuous` |
| 프리뷰 카드 | 10pt | `.continuous` |
| 토스트 | 10pt | `.continuous` |

---

## 5. Components (UI 컴포넌트)

### 5.1 Builder Shell

빌더 셸은 모든 선택과 결과를 한 패널 안에 담는 기본 레이아웃입니다.

구성:
- 헤더
- 현재 선택 breadcrumb
- 선택 영역
- 초안 입력
- 프롬프트 미리보기
- 액션 바

상태 원칙:
- 사용자는 항상 "지금 어느 단계에 있는지" 알아야 함
- 현재 선택 요약은 상단에 고정
- 미리보기는 너무 늦게 나타나면 안 됨. 가능한 빨리 가시화
- 긴 프리뷰 상태에서는 입력 영역과 preview를 시각적으로 분리된 card layer로 유지

### 5.2 Topic Selector

#### 역할
- 현재 프롬프트를 쓰는 상황을 고르는 첫 단계
- MVP에서는 `코딩` 하나만 제공하지만, 빈 상태가 아니라 "확장 가능한 구조"를 보여주는 역할

#### 표현
- 단일 대형 chip 또는 segmented control 형태
- 선택 후 하단 소주제 섹션 활성화

```
╭──────────────╮
│  </> 코딩     │
╰──────────────╯
```

### 5.3 Subtopic Selector

#### 역할
- 이번 요청의 핵심 목적을 하나로 좁힘
- 선택이 곧 UI 전체의 중심축이 됨

#### 표현 원칙
- 수평 scroll chip row 또는 2열 grid
- 선택된 항목은 accent 배경 + border 강조
- 한 번에 하나만 선택 가능

#### 기본 예시
- 최초 기획
- 기획 수정
- 구현 작업
- 리팩토링 작업
- 오류 개선
- 테스트
- 기능 추가
- 기능 삭제

### 5.4 Keyword Chips

#### 역할
- 사용자의 관심사와 요구사항을 클릭으로 수집
- 겉보기에 모두 같은 칩이지만 내부적으로는 서로 다른 프롬프트 슬롯을 채움

#### 그룹 구조
- 작업 대상
- 우선순위
- 제약조건
- 출력 방식
- 검증 요구

#### 노출 전략
- 소주제마다 모든 그룹을 다 보여주지 않는다
- 그룹은 중요도 순서로 최대 3개까지 우선 노출
- 기본 노출 칩은 그룹당 2~4개
- `더 보기` 이전에는 고빈도, 추천 키워드만 보여준다

#### 칩 상태

| 상태 | 배경 | 텍스트 | 인터랙션 |
|------|------|--------|----------|
| 기본 | transparent | `text.primary` | hover 가능 |
| hover | `surface.hover` | `text.primary` | 클릭 가능 |
| selected | `accent.subtle` | `text.accent` | 토글 해제 가능 |
| disabled | `surface.sunken` | `text.tertiary` | 클릭 불가 |

```
기본        선택됨         비활성
[Swift]    [✓ Swift]      [Swift]
```

칩 배치 원칙:
- 첫 줄에는 추천 키워드를 둔다
- 한 줄에 3~5개 정도의 스캔 밀도를 유지한다
- 한 그룹이 2줄을 넘기기 시작하면 기본 노출이 과한 것으로 본다

### 5.5 Prompt Draft Editor

#### 역할
- 사용자의 짧은 문장을 받는 영역
- 장문의 에세이를 요구하지 않음

#### UI 요구사항
- 멀티라인 `TextEditor`
- 입력이 짧아도 어색하지 않도록 충분한 여백
- placeholder 예시 제공

추천 placeholder:
- "무엇을 바꾸고 싶은지 한두 문장으로 적어보세요"
- "예: SwiftUI 설정 화면에서 API 키 저장 구조를 정리하고 싶다"

### 5.6 Prompt Preview Card

#### 역할
- 앱이 현재 무엇을 만들고 있는지 즉시 보여줌
- 선택 변경에 따라 실시간 업데이트

#### 시각 원칙
- 모노스페이스 기반
- 읽기 전용 preview와 editable mode를 토글 가능
- 너무 긴 경우 내부 스크롤 허용
- preview 텍스트는 solid card 위에서 읽히게 하고, 배경 blur와 직접 섞지 않는다

```
Prompt Preview
╭──────────────────────────────────────────────╮
│ Current Situation: ...                       │
│ Task Type: 오류 개선                         │
│ Constraints: 최소 수정, 새 의존성 금지      │
│ User Draft: ...                              │
╰──────────────────────────────────────────────╯
```

### 5.7 Reference Document Chips

#### 역할
- 프로젝트 문서, 전역 문서, 외부 Markdown 문서를 현재 프롬프트에 붙이는 레이어

#### 표현
- 파일 이름 chip
- scope badge: `GLOBAL`, `PROJECT`, `EXTERNAL`
- 제거 버튼 포함

```
[repo-rules.md · PROJECT]
[writing-style.md · GLOBAL]
```

### 5.8 Action Bar

#### 주요 액션
- `프롬프트 생성` 또는 자동 생성 상태 표시
- `다듬기`
- `영문 번역`
- `복사`

#### 원칙
- 기본 Primary Action은 `복사`
- `다듬기`, `영문 번역`은 secondary
- LLM 미설정 상태에서는 해당 버튼 비활성화 + 설명 제공
- 액션 바는 preview 바로 아래에 붙여 결과와 액션 사이 거리를 줄인다

### 5.9 Toast Notification

```
╭────────────────────────────────────╮
│ ✓ 클립보드에 복사됨                │
╰────────────────────────────────────╯
```

종류:
- 성공: 복사 완료
- 정보: 영문 버전 생성 완료
- 경고: 문서가 누락되어 제외됨
- 오류: LLM 요청 실패

### 5.10 Preferences Window

탭 구성:
- 일반
- AI 설정
- 문서 자산
- 단축키

문서 자산 탭 예시:

```
┌─ Global Documents ─────────────────────────────┐
│ writing-style.md                         [제거] │
│ repo-rules.md                            [제거] │
│                                              + │
└────────────────────────────────────────────────┘
```

### 5.11 MenuBar Icon & Menu

메뉴바 메뉴는 간결해야 합니다.

- 패널 열기
- 최근 프롬프트 다시 열기
- 설정
- 종료

아이콘 기본:
- `sparkles` 또는 `slider.horizontal.3`

---

## 6. Motion & Animation (모션과 애니메이션)

### 6.1 원칙

| 원칙 | 설명 |
|------|------|
| **상태 설명용 모션만 사용** | 선택 결과를 더 잘 읽게 만드는 모션만 허용 |
| **즉시 반응** | 칩 선택은 80~120ms 수준으로 즉시 느껴져야 함 |
| **레이아웃 변화는 부드럽게** | 프리뷰 확장, 키워드 그룹 노출 시 abrupt jump 금지 |
| **한 번에 하나의 강조** | 선택, 로딩, 성공을 동시에 크게 흔들지 않는다 |

### 6.2 Animation Catalog

| 요소 | 등장 | 사라짐 | Curve | Duration |
|------|------|--------|-------|----------|
| Floating Panel | fade-in + scale | fade-out + scale | `.easeOut` | 200ms / 150ms |
| 소주제 선택 | 배경색 전환 | 배경 복귀 | `.easeInOut` | 100ms |
| 키워드 선택 | 배경색 + 체크 아이콘 | 역전환 | `.easeInOut` | 90ms |
| 프리뷰 갱신 | opacity + height | — | `.easeOut` | 180ms |
| 토스트 | slide-up + fade-in | fade-out | `.easeOut` | 220ms / 180ms |
| 번역/다듬기 상태 | subtle pulse | 정지 | `.easeInOut` | 1.2s loop |

### 6.3 Reduce Motion

macOS `Reduce Motion`이 활성화되면:
- scale 애니메이션 제거
- opacity 전환만 유지
- pulse/shimmer 제거

---

## 7. Iconography (아이콘)

### 7.1 원칙

- **SF Symbols만 사용**
- 아이콘은 의미 보조용이지 장식용이 아님
- 키워드 칩에는 필요할 때만 아이콘 사용

### 7.2 Icon Mapping

| 요소 | SF Symbol | 비고 |
|------|-----------|------|
| 대주제: 코딩 | `chevron.left.forwardslash.chevron.right` | 또는 `hammer` 계열은 피함 |
| 최초 기획 | `lightbulb` | 아이디어/설계 |
| 구현 작업 | `wrench.and.screwdriver` | 제작 |
| 리팩토링 | `arrow.triangle.2.circlepath` | 구조 변경 |
| 오류 개선 | `ant` | 버그 수정 |
| 테스트 | `checkmark.shield` | 검증 |
| 기능 추가 | `plus.circle` | 추가 |
| 기능 삭제 | `minus.circle` | 제거 |
| 참고 문서 | `doc.text` | 문서 자산 |
| 영문 번역 | `globe` | 번역 |
| 복사 | `doc.on.doc` | clipboard |
| 다듬기 | `sparkles` | LLM refinement |

---

## 8. Sound & Haptics (사운드)

기본적으로 사운드는 사용하지 않습니다. 성공/에러 상태는 토스트와 시각 상태로 충분히 전달합니다.

---

## 9. Design Tokens — Swift 구현 가이드

### 9.1 Color Token 정의

```swift
import SwiftUI

extension Color {
    static let surfaceRoot = Color(nsColor: .windowBackgroundColor)
    static let surfaceBase = Color(nsColor: .controlBackgroundColor)
    static let surfaceElevated = Color(nsColor: .controlColor)

    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(nsColor: .tertiaryLabelColor)

    static let accent = Color(
        light: Color(red: 0.353, green: 0.294, blue: 0.820),
        dark: Color(red: 0.424, green: 0.361, blue: 0.906)
    )
    static let accentSubtle = Color.accent.opacity(0.12)
    static let accentHover = Color(
        light: Color(red: 0.424, green: 0.361, blue: 0.906),
        dark: Color(red: 0.490, green: 0.435, blue: 0.941)
    )

    static let statusError = Color(nsColor: .systemRed)
    static let statusSuccess = Color(nsColor: .systemGreen)
    static let statusWarning = Color(nsColor: .systemYellow)

    static let borderDefault = Color.primary.opacity(0.08)
    static let borderSubtle = Color.primary.opacity(0.04)
    static let borderFocus = Color.accent
}
```

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
    static let editor: CGFloat = 10
    static let chip: CGFloat = 8
    static let card: CGFloat = 10
    static let toast: CGFloat = 10
}
```

### 9.4 Typography Token

```swift
enum Typography {
    static let display = Font.system(size: 18, weight: .bold)
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

### 구조
- [ ] 대주제 -> 소주제 -> 키워드 흐름이 한눈에 보인다
- [ ] 현재 선택 상태가 상단에서 항상 확인 가능하다
- [ ] 프롬프트 미리보기가 충분히 빨리 나타난다
- [ ] 선택을 바꿔도 초안 입력이 불필요하게 초기화되지 않는다
- [ ] 초기 화면의 키워드 수가 과도하지 않다 (8~12개 범위)

### 시각적 일관성
- [ ] 선택 칩의 상태 변화가 일관되다
- [ ] Accent 사용이 과하지 않고, 선택 강조에 집중되어 있다
- [ ] Light / Dark Mode 모두에서 chip, preview, action bar 대비가 충분하다
- [ ] 모노스페이스 프리뷰가 읽기 쉽다
- [ ] 큰 패널에서도 blur보다 내부 card surface가 읽기성을 지탱한다

### 접근성
- [ ] 키보드만으로 전체 플로우 수행 가능
- [ ] VoiceOver가 선택 상태를 읽어준다
- [ ] 칩 상태가 색상만으로 구분되지 않는다
- [ ] 텍스트 대비율 WCAG AA 충족

### 모션
- [ ] 선택 피드백이 120ms 이내로 체감된다
- [ ] 프리뷰 확장/축소가 부드럽다
- [ ] Reduce Motion에서 핵심 경험이 유지된다

### 제품 적합성
- [ ] 화면이 "텍스트 입력기"보다 "사고를 좁히는 빌더"처럼 느껴진다
- [ ] 클릭 몇 번으로 사용자의 의도가 실제로 더 구체화된다
- [ ] 다듬기/번역 버튼 없이도 기본 가치가 성립한다
