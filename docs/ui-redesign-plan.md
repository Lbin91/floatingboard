# UI/UX 수정 계획서: Draft 중심 레이아웃 개선

## 1. 현황 분석

### 1.1 현재 레이아웃 구조와 비율

패널 기본 크기는 **760 x 640pt** (최소 680 x 560pt)이며, 두 개의 수직 컬럼으로 나뉘어 있다.

```
PromptBuilderView.swift:13-19 (HStack 구조)
┌──────────────────────────────────────────────────────────┐
│  Header (14pt vertical padding)                          │  ~46pt
├────────────┬─────────────────────────────────────────────┤
│            │                                             │
│  선택 컬럼  │           편집 컬럼                         │
│  280pt 고정 │     나머지 공간 (~480pt)                     │
│  (37%)     │         (63%)                               │
│            │                                             │
│  Topic     │  Draft Editor (118pt 고정)                   │
│  Subtopic  │  Prompt Preview (minHeight 220pt)            │
│  Keywords  │  Action Bar                                  │
│            │                                             │
├────────────┴─────────────────────────────────────────────┤
```

**수평 비율**: 선택 컬럼 280pt(37%) : 편집 컬럼 ~480pt(63%)

**수직 공간 배분** (640pt 기준):
| 영역 | 코드 위치 | 높이 | 비중 |
|------|-----------|------|------|
| Header | `PromptBuilderView.swift:25-49` | ~46pt | 7.2% |
| 선택 컬럼 (좌측 전체) | `PromptBuilderView.swift:51-77` | ~594pt | 92.8% |
| Draft Editor | `PromptDraftEditorView.swift:16` (`frame(height: 118)`) | 118pt + label 26pt = ~144pt | 22.5% |
| Prompt Preview | `PromptPreviewView.swift:87` (`frame(minHeight: 220)`) | 220pt+ + mode bar ~50pt = ~270pt+ | 42.2%+ |
| Action Bar | `ActionBarView.swift:16-89` | ~36pt | 5.6% |

**편집 컬럼 내부 비율** (480pt 폭, 594pt 높이):
- Draft + Preview + ActionBar 합산: ~450pt
- 남은 여백 (padding 18pt x2): ~144pt 분산

### 1.2 발견된 문제점

#### 문제 A: 선택 컬럼의 과도한 공간 점유

선택 컬럼은 **280pt 고정 폭**(`PromptBuilderView.swift:75`)을 차지한다. MVP에서 Topic은 "코딩" 단 하나뿐임에도 `TopicSelectorView`가 하나의 chip row로 전체 너비를 사용한다. Subtopic은 최대 8개이고, 키워드 그룹은 소주제당 4-5개 그룹이 노출된다.

그러나 선택 영역은 "클릭 기반 수집"이라는 design-system 철학에 따라 **빠르게 완료하고 넘어가야 하는 보조 단계**다. 현재 레이아웃은 선택 영역에 화면의 37%를 고정 할당하여, Draft와 Preview라는 실제 작업 공간을 압박하고 있다.

#### 문제 B: Draft Editor의 축소된 높이

`PromptDraftEditorView.swift:16`에서 `frame(height: 118)`으로 **고정 118pt** 높이를 가진다. 이것은 약 6-7줄의 텍스트만 수용 가능하다. 사용자 피드백에 따르면 "Draft 작성이 주가 되어야 한다"지만, 현재 Draft는 Preview(최소 220pt)보다 절반 이하 공간만 받고 있다.

Draft는 사용자가 **자신의 의도를 직접 서술하는 핵심 영역**이다. 키워드 선택으로 "사고를 좁힌 후" 최종 프롬프트의 방향을 결정하는 곳이 바로 이 영역인데, 시각적 비중이 그 역할에 맞지 않는다.

#### 문제 C: 선택-편집의 수평 분할이 시선을 분산시킴

현재 좌-우 분할 레이아웃은:
1. 왼쪽에서 선택 (Topic > Subtopic > Keywords)
2. 오른쪽에서 작성 (Draft > Preview)

사용자의 시선이 좌-우를 반복해서 오가야 한다. 특히 키워드를 선택하면서 Preview의 변화를 확인하려면 시선이 두 컬럼 사이를 지속적으로 이동해야 한다. design-system.md의 "Single Focus" 원칙과 충돌한다.

#### 문제 D: TopicSelector의 낭비

MVP에서 Topic은 "코딩" 하나뿐이다. `TopicSelectorView`는 `HStack` 내 `ForEach`로 chip을 생성하며(`TopicSelectorView.swift:14-23`), chip 하나가 `maxWidth: .infinity`로 row 전체를 차지한다. 단일 Topic을 표시하기 위해 280pt 컬럼의 상단 전체 너비를 사용하는 것은 비효율적이다.

#### 문제 E: KeywordPickerView의 스크롤 독점

`KeywordPickerView`는 visibility rule에 따라 최대 5개 그룹(작업 대상, 우선순위, 제약조건, 출력 방식, 검증 요구)을 표시한다. 각 그룹이 평균 4-10개 키워드를 포함하므로, "구현 작업" 소주제의 경우 최대 **26개 키워드**가 노출된다(`coding.json:1125-1161`의 `visibleKeywordIDs` 참조). 이것이 280pt 컬럼의 대부분을 채우며, `ScrollView`로 감싸져 있지만(`PromptBuilderView.swift:52`) 선택 컬럼 전체가 길어진다.

design-system.md 4.4절 "키워드 노출 밀도"에서 "초기 총 노출 키워드 수: 8-12개"를 권장하고 있으나, 현재 `coding.json`의 visibility rules은 이 가이드를 크게 상회하고 있다.

### 1.3 사용자 플로우 관점의 병목

```
현재 플로우:
1. 좌측에서 Topic 확인 (의미 없음 - 코딩 하나뿐)
2. 좌측에서 Subtopic 선택 (8개 중 1개)
3. 좌측에서 Keywords 선택 (4-5 그룹, 다수 클릭)
4. 우측 상단 Draft 작성 (118pt 제한)
5. 우측 중간 Preview 확인 (220pt 최소)
6. 우측 하단 Action 실행

시선 이동: 좌→우→좌→우→우→우 (총 3회 전환)
```

이상적인 플로우는 시선이 위에서 아래로 흐르는 단방향이어야 한다.

---

## 2. 개선 방향

### 2.1 핵심 원칙: Draft 작성이 주, 선택은 보조

| 원칙 | 현재 | 개선 후 |
|------|------|---------|
| 수평 구조 | 좌(선택 37%) : 우(편집 63%) | **단일 컬럼, 상하 구조** 또는 **접이식 선택 + 넓은 편집** |
| Draft 비중 | 118pt 고정 (22.5%) | **가변 높이, 최소 180pt (35%+)** |
| Preview 비중 | minHeight 220pt (42%+) | **minHeight 200pt 유지, maxWidth 확대** |
| 선택 비중 | 280pt 컬럼 전체 | **접이식 패널 또는 축소된 상단 섹션 (20-30%)** |

### 2.2 레이아웃 비율 변경안

#### 안 A: 상하 단일 컬럼 (권장)

design-system.md 4.2절의 원래 와이어프레임(수직 흐름)에 부합하는 구조다.

```
┌──────────────────────────────────────────────────────────┐
│  Header: "Prompt Builder" + Subtopic title    [Close]    │  ~46pt
├──────────────────────────────────────────────────────────┤
│  Topic pill (인라인) │ Subtopic chips (수평 스크롤)       │  ~60pt
├──────────────────────────────────────────────────────────┤
│  Keyword groups (접이식, 초기 2줄만 노출)                │  ~80-140pt
│  [작업 대상: Swift ✓  API ✓  UI]                         │
│  [우선순위: 안정성 ✓  단순성]  ...더 보기                 │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Draft Editor (확장됨, 최소 180pt)                       │  180-280pt
│  ┌──────────────────────────────────────────────────────┐│
│  │ 무엇을 바꾸고 싶은지 한두 문장으로 적어보세요        ││
│  │                                                      ││
│  │                                                      ││
│  └──────────────────────────────────────────────────────┘│
├──────────────────────────────────────────────────────────┤
│  Prompt Preview (mode tabs 포함)                         │  200pt+
│  ┌──────────────────────────────────────────────────────┐│
│  │ Current Situation: ...                               ││
│  │ Task Type: ...                                       ││
│  └──────────────────────────────────────────────────────┘│
├──────────────────────────────────────────────────────────┤
│  [Refine] [Translate] [Regenerate]          [Copy]       │  ~36pt
└──────────────────────────────────────────────────────────┘
```

**비율** (640pt 기준):
| 영역 | 높이 | 비중 |
|------|------|------|
| Header | ~46pt | 7.2% |
| Topic + Subtopic | ~60pt | 9.4% |
| Keywords (접힘) | ~100pt | 15.6% |
| **Draft Editor** | **~220pt** | **34.4%** |
| **Prompt Preview** | **~230pt** | **36.0%** |
| Action Bar | ~36pt | 5.6% |

Draft + Preview가 전체의 **70.4%** 를 차지한다. (현재 64.7%에서 상향)

#### 안 B: 좌측 접이식 + 우측 확장 (대안)

좌측 컬럼을 유지하되 폭을 줄이고 접기/펼치기 기능을 추가한다.

```
┌──────────────────────────────────────────────────────────┐
│  Header                                                  │  ~46pt
├──────────┬───────────────────────────────────────────────┤
│ [V 선택] │                                               │
│ Subtopic │  Draft Editor (180pt+)                        │
│ Keywords │  Prompt Preview (240pt+)                      │
│ (접힘)   │  Action Bar                                   │
│ 200pt    │  ~560pt                                       │
├──────────┴───────────────────────────────────────────────┤
```

선택 컬럼을 200pt로 축소하고 접기 가능하게 하면, 편집 컬럼이 ~560pt를 확보한다.

#### 비교 및 권장

| 기준 | 안 A (상하 단일) | 안 B (접이식 좌측) |
|------|------------------|---------------------|
| 시선 흐름 | 단방향 (위→아래) | 양방향 (좌→우 반복) |
| Draft 공간 | 넓음 (전체 폭) | 넓음 (560pt) |
| Keyword 스크롤 | 접이식으로 해결 | 독립 스크롤 가능 |
| design-system 부합 | 4.2절 원본 와이어프레임과 일치 | 현재 구조의 개선 |
| 구현 난이도 | 중 (재구성 필요) | 낮 (폭 조정 + 토글) |
| ViewModel 호환 | 완전 호환 | 완전 호환 |

**권장: 안 A (상하 단일 컬럼)**. 시선 흐름의 일관성과 design-system.md 원본 철학에 가장 부합한다. 안 B는 최소 변경으로 개선이 필요할 때 선택한다.

---

## 3. 수정 항목

### 3.1 PromptBuilderView.swift — 메인 레이아웃 재구성

**현재** (`PromptBuilderView.swift:7-23`):
```swift
// HStack 기반 좌-우 분할
HStack(spacing: 0) {
    selectionColumn      // 280pt 고정
    Divider()
    editingColumn        // 나머지
}
.frame(minWidth: 680, idealWidth: 760, minHeight: 560, idealHeight: 640)
```

**변경 안 A 적용 시**:
```swift
// VStack 기반 상-하 흐름
VStack(spacing: 0) {
    header

    Divider()

    // 선택 영역: Topic(인라인) + Subtopic + Keywords(접이식)
    compactSelectionBar

    Divider()

    // 편집 영역: Draft(확장) + Preview + Action
    ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            PromptDraftEditorView(...)    // height: 180 가변
            PromptPreviewView(...)
            ActionBarView(...)
        }
        .padding(18)
    }
}
.frame(minWidth: 560, idealWidth: 640, minHeight: 560, idealHeight: 680)
```

주요 변경:
- `HStack` -> `VStack` 전환
- `selectionColumn` -> `compactSelectionBar`로 축약 (Topic + Subtopic + Keywords를 수평 압축)
- `editingColumn`이 전체 폭을 사용
- 패널 최소 폭을 560pt로 축소 (좌측 컬럼 제거로 여유 확보)
- 패널 이상적 높이를 680pt로 증가 (Draft 공간 확보)

### 3.2 TopicSelectorView.swift — 인라인 pill로 축소

**현재** (`TopicSelectorView.swift:8-27`):
```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Topic").font(.subheadline.weight(.semibold))
    HStack(spacing: 8) {
        ForEach(topics, ...) { topic in
            Button { ... }
                .frame(maxWidth: .infinity)  // 전체 너비 확장
        }
    }
}
```

**변경**:
- "Topic" 레이블 제거 (MVP에서 의미 없음)
- 단일 pill/badge로 표시: `[</> 코딩]` (클릭 불가 또는 토글)
- SubtopicSelector 옆에 인라인 배치

```swift
// CompactTopicPillView로 교체
struct CompactTopicPillView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(Color.accentColor.opacity(0.1)))
            .overlay(Capsule().stroke(Color.accentColor.opacity(0.3), lineWidth: 1))
    }
}
```

### 3.3 SubtopicSelectorView.swift — 수평 스크롤 chip row

**현재** (`SubtopicSelectorView.swift:10-29`):
```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Subtopic").font(...)
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)]) { ... }
}
```

**변경**:
- "Subtopic" 레이블 생략 (Header에 선택된 Subtopic title이 이미 표시됨, `PromptBuilderView.swift:117-119`)
- `LazyVGrid` -> `ScrollView(.horizontal)` + `HStack`으로 변경
- chip 크기 축소: `minimum: 104` -> `minimum: 80`
- Topic pill과 같은 행에 배치

```swift
HStack(spacing: 8) {
    CompactTopicPillView(title: "코딩")

    Divider().frame(height: 20)

    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 6) {
            ForEach(subtopics, ...) { subtopic in
                Button { ... }
                    .buttonStyle(CompactChipStyle(...))
            }
        }
    }
}
```

### 3.4 KeywordPickerView.swift — 접이식 그룹 + "더 보기"

**현재** (`KeywordPickerView.swift:11-42`):
```swift
VStack(alignment: .leading, spacing: 12) {
    ForEach(groups, ...) { group in
        VStack(alignment: .leading, spacing: 8) {
            Text(group.title)                    // 그룹 라벨
            LazyVGrid(columns: [...]) {          // 전체 키워드 노출
                ForEach(keywords...) { ... }
            }
        }
    }
}
```

**변경**:
- 초기에 **2개 그룹만 노출**, 나머지는 "더 보기" 토글로 숨김
- 각 그룹당 **최대 4개 키워드**만 기본 노출
- `maxVisibleKeywords` 속성 활용 (`coding.json`의 `keywordGroups[].maxVisibleKeywords`)
- 그룹 제목을 인라인 pill로 축소
- 수평 배치로 전환하여 공간 절약

```swift
// CollapsibleKeywordPickerView
struct CollapsibleKeywordPickerView: View {
    let groups: [KeywordGroup]
    // ...
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 초기: 처음 2개 그룹, 각 4개 키워드
            let displayGroups = isExpanded ? groups : Array(groups.prefix(2))

            ForEach(displayGroups, ...) { group in
                HStack(spacing: 6) {
                    Text(group.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    // 키워드를 수평으로 나열
                    let visibleKeywords = isExpanded
                        ? keywordsForGroup(group.id)
                        : Array(keywordsForGroup(group.id).prefix(4))

                    ForEach(visibleKeywords, ...) { keyword in
                        Button { ... }
                            .buttonStyle(MiniChipStyle(...))
                    }
                }
            }

            if groups.count > 2 {
                Button(isExpanded ? "접기" : "더 보기 (\(groups.count - 2)개 그룹)") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundStyle(.accent)
            }
        }
    }
}
```

### 3.5 PromptDraftEditorView.swift — 높이 확장

**현재** (`PromptDraftEditorView.swift:16`):
```swift
.frame(height: 118)
```

**변경**:
```swift
.frame(minHeight: 140, idealHeight: 200, maxHeight: .infinity)
```

- `minHeight`: 118 -> **140pt** (최소 보장)
- `idealHeight`: 신규 **200pt** (기본 높이 상향)
- `maxHeight`: `.infinity` (Preview와 flexibly 공간 분할)
- placeholder 텍스트 추가: design-system.md 5.5절의 "무엇을 바꾸고 싶은지 한두 문장으로 적어보세요"

### 3.6 PromptPreviewView.swift — 폭 확대 및 최소 높이 미세 조정

**현재** (`PromptPreviewView.swift:87,100,116,133`):
```swift
.frame(minHeight: 220, maxHeight: .infinity)
```

**변경**:
- 전체 폭 사용으로 Preview의 가독성 대폭 향상 (280pt 제약 해제)
- `minHeight: 220` 유지 (충분한 프리뷰 공간)
- mode segment picker 폭 제한(`frame(maxWidth: 340)` 제거) -> 전체 폭 활용

### 3.7 ActionBarView.swift — 간격 최적화

**현재**: 큰 변화 불필요. 전체 폭 사용으로 버튼 간격이 자연스럽게 개선됨.

선택적 개선:
- `Refine` / `Translate`을 아이콘만으로 표시하거나 더 컴팩트하게
- 복사 버튼을 우측 끝으로 고정 (`Spacer()` 유지)

### 3.8 FloatingPanelController.swift — 패널 크기 조정

**현재** (`FloatingPanelController.swift:35,48`):
```swift
contentRect: NSRect(x: 0, y: 0, width: 760, height: 640)
panel.minSize = NSSize(width: 680, height: 560)
```

**변경 (안 A 기준)**:
```swift
contentRect: NSRect(x: 0, y: 0, width: 640, height: 680)  // 폭 축소, 높이 증가
panel.minSize = NSSize(width: 560, height: 560)
```

좌측 컬럼 제거로 폭은 줄어도 되며, Draft 공간 확보를 위해 높이를 늘린다.

---

## 4. 구현 순서

### Phase 1: 구조 전환 (핵심, 안 A 기준)

**목표**: HStack에서 VStack으로 레이아웃 전환, 즉시 Draft 공간 확보

| 순서 | 파일 | 작업 내용 |
|------|------|-----------|
| 1-1 | `PromptBuilderView.swift` | `HStack` -> `VStack` 전환. `selectionColumn` + `editingColumn` -> `compactSelectionBar` + `ScrollView { editingArea }` |
| 1-2 | `PromptBuilderView.swift` | `selectionColumn` 제거, `compactSelectionBar` computed property 추가 |
| 1-3 | `FloatingPanelController.swift` | 기본 contentRect 폭/높이 조정 (640x680), minSize 변경 (560x560) |
| 1-4 | `PromptDraftEditorView.swift` | `frame(height: 118)` -> `frame(minHeight: 140, idealHeight: 200, maxHeight: .infinity)` |

**검증**: 빌드 성공 + Topic/Subtopic/Keyword/Draft/Preview가 모두 정상 동작

### Phase 2: 선택 영역 압축

**목표**: 선택 영역을 한 행에 배치하고 공간 최소화

| 순서 | 파일 | 작업 내용 |
|------|------|-----------|
| 2-1 | `TopicSelectorView.swift` | `CompactTopicPillView` 추가 (또는 TopicSelectorView를 inline pill로 재구현) |
| 2-2 | `SubtopicSelectorView.swift` | `LazyVGrid` -> `ScrollView(.horizontal)` + `HStack`으로 변경, chip 크기 축소 |
| 2-3 | `PromptBuilderView.swift` | `compactSelectionBar`에 Topic pill + Subtopic chips를 같은 `HStack`에 배치 |

**검증**: 선택 영역이 60pt 이내 높이에 배치되는지 확인

### Phase 3: Keywords 접이식 구현

**목표**: 키워드 그룹을 접었다 펼 수 있게 하여 초기 화면 높이 제어

| 순서 | 파일 | 작업 내용 |
|------|------|-----------|
| 3-1 | `KeywordPickerView.swift` | 접이식 로직 추가 (`@State isExpanded`), 그룹당 키워드 수 제한, "더 보기" 버튼 |
| 3-2 | `KeywordPickerView.swift` | 애니메이션 적용 (`withAnimation(.easeInOut(duration: 0.2))`) |
| 3-3 | `PromptBuilderView.swift` | `compactSelectionBar` 하단에 접이식 Keywords 배치 |

**검증**: 초기 상태에서 Keywords가 2개 그룹, 80-100pt 이내 높이에 배치되는지 확인. "더 보기" 토글 동작 확인.

### Phase 4: 세부 조정

**목표**: 폴리싱 및 디자인 시스템 일관성 확보

| 순서 | 파일 | 작업 내용 |
|------|------|-----------|
| 4-1 | `PromptDraftEditorView.swift` | placeholder 텍스트 추가 (localized) |
| 4-2 | `PromptPreviewView.swift` | segment picker 폭 제한 제거, 전체 폭 활용 |
| 4-3 | `ActionBarView.swift` | 버튼 레이아웃 미세 조정 (전체 폭 활용) |
| 4-4 | `PromptBuilderView.swift` | `PromptPreviewView` 내부 레이아웃 재조정 ( minHeight 값 검증) |
| 4-5 | `FloatingPanelController.swift` | 최종 패널 크기 확정, resize 동작 테스트 |

**검증**: 전체 플로우 동작 확인, Light/Dark 모드 외관 확인, 키보드 접근성 확인

---

## 5. 검증 기준

### 5.1 완료 판정 기준

| # | 기준 | 측정 방법 |
|---|------|-----------|
| 1 | Draft Editor의 기본 높이가 180pt 이상 | `PromptDraftEditorView.swift`의 `idealHeight` 값 확인 |
| 2 | 선택 영역이 전체 화면 높이의 30% 이하 (초기 상태) | Keywords 접힘 상태에서 측정 |
| 3 | Draft + Preview가 전체 화면 높이의 65% 이상 차지 | 레이아웃 비율 계산 |
| 4 | 사용자 시선이 위->아래로 단방향 흐름 | Topic > Subtopic > Keywords > Draft > Preview > Action 순서 배치 |
| 5 | 빌드 성공 및 기존 테스트 통과 | `xcodebuild test` 실행 |
| 6 | ViewModel 변경 없이 구현 완료 | `PromptBuilderViewModel.swift` 미수정 |
| 7 | Light/Dark 모드 모두 정상 표시 | 수동 확인 |
| 8 | 패널 resize 시 Draft/Preview가 유연하게 대응 | `maxHeight: .infinity` 동작 확인 |
| 9 | "더 보기" 토글이 200ms 이내 부드럽게 동작 | 애니메이션 타이밍 확인 |
| 10 | 키워드 선택 시 Preview 실시간 업데이트 유지 | 기존 동작 회귀 없음 |

### 5.2 회귀 방지 체크리스트

- [ ] 키워드 선택/해제가 Preview에 즉시 반영됨
- [ ] Draft 텍스트 입력이 Preview에 반영됨
- [ ] Subtopic 변경 시 키워드 초기화 및 기본값 로드
- [ ] Copy 버튼이 클립보드에 정상 복사
- [ ] Refine / Translate 버튼 동작 유지
- [ ] 세션 복원 (Draft restore) 정상 동작
- [ ] 패널 열기/닫기 핫키 정상 동작
- [ ] `FloatingPanelControllerTests.swift` 통과
- [ ] `PromptBuilderViewModelTests.swift` 통과

### 5.3 design-system 철학 준수 확인

| 철학 | 준수 여부 확인 |
|------|---------------|
| 사고 분해 (Decomposition First) | 선택이 먼저 오고 Draft가 뒤에 오는 순서 유지 |
| 집중 유지 (Single Focus) | 시선 단방향 흐름으로 집중력 향상 |
| 클릭 기반 수집 (Curated Collection) | Keywords 접이식으로 초기 노출 제한 (8-12개 권장) |
| 편집 가능한 결과 (Editable Output) | Draft 공간 확대로 직접 작성 장려 |
| 맥락 존중 (Context Matters) | Preview 전체 폭 사용으로 가독성 향상 |
| 네이티브 절제 (Native Restraint) | SF Pro, 시스템 색상, 절제된 애니메이션 유지 |
