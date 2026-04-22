# Selection UI 개선 계획서

## 1. 목표

Selection 영역을 Draft 작성의 보조 입력 도구로 재설계한다. 사용자는 `Draft -> Selection -> Action` 흐름 안에서 소주제와 키워드를 고른다.

현재 `PromptPreviewView`는 `PromptBuilderView` 뷰 계층에서 이미 제거되어 있다. 이 계획서는 Preview 제거 작업을 포함하지 않으며, Selection 영역의 구조와 상호작용만 다룬다.

핵심 목표:
- Draft 영역은 고정 높이로 유지한다.
- Selection은 접이식 카드가 아니라 명확한 작업 영역으로 만든다.
- 상위 항목(Subtopic)은 선택 후 한 줄 요약으로 접고, 그 줄을 클릭하면 다시 선택 화면으로 돌아간다.
- Keyword 선택 화면은 읽기 쉬운 행 단위 레이아웃을 사용한다.

## 2. 현재 문제

현재 `PromptBuilderView`의 Selection은 `selectionDisclosure` 형태다.

문제점:
- Selection 제목, 화살표, summary, 카드 여백이 실제 선택 컨트롤보다 더 큰 비중을 가진다.
- Subtopic과 Keyword가 같은 스크롤 영역 안에 한꺼번에 들어가 가독성이 낮다.
- 상위 항목을 이미 선택한 뒤에도 Subtopic 전체가 계속 노출되어 공간을 낭비한다.
- Keyword group은 세로 스택으로만 나열되어 그룹명과 선택지가 한눈에 연결되지 않는다.

## 3. 권장 UX 패턴

`drill-down + summary row` 패턴을 사용한다.

### 3.1 Subtopic 선택 모드

초기 진입 또는 summary row 클릭 시 표시한다.

```text
┌ Selection ───────────────────────────────┐
│ Subtopic                                 │
│ [기획] [구현] [리팩토링] [오류 개선]      │
│ [테스트] [기능 추가] [삭제]              │
└──────────────────────────────────────────┘
```

동작:
- Subtopic chip을 클릭하면 `viewModel.selectSubtopic(id)`를 호출한다.
- 선택 직후 Selection step을 keyword 모드로 전환한다.
- 초기 진입 시에도 사용자가 명시적으로 Subtopic을 고르는 화면을 먼저 보여주는 것이 목표다.

### 3.2 Keyword 선택 모드

Subtopic이 선택된 뒤 표시한다.

```text
┌ Selection ───────────────────────────────┐
│ 구현 · 3 keywords                   >  │
│                                          │
│ 작업 대상   [Swift] [UI] [API]          │
│ 우선순위     [안정성] [단순성] [성능]    │
│ 제약조건     [No deps] [Small diff]      │
│ 출력 방식    [Patch] [Plan] [Checklist]  │
│ 검증 요구    [Tests] [Build]             │
└──────────────────────────────────────────┘
```

동작:
- 첫 줄은 현재 선택된 Subtopic summary row다.
- summary row에는 선택된 Subtopic 제목과 선택된 keyword 개수를 표시한다.
- 선택된 keyword가 있으면 최대 2개까지 보조 텍스트로 표시할 수 있다.
- summary row 전체를 클릭하면 Subtopic 선택 모드로 돌아간다.
- Keyword chips는 기존 `viewModel.toggleKeyword(_:)`를 그대로 사용한다.

## 4. 상태 모델

View 전용 상태로 충분하다.

```swift
private enum SelectionStep {
    case subtopic
    case keywords
}
```

권장 규칙:
- 초기 진입은 `.subtopic`을 기본값으로 둔다.
- Subtopic chip을 사용자가 직접 선택하면 `.keywords`.
- Summary row 클릭 시 `.subtopic`.
- 외부에서 selectedSubtopic이 바뀌어도 사용자가 summary row를 열어 둔 상태라면 `.subtopic`을 유지한다.

현재 `PromptBuilderViewModel.refreshSubtopics()`는 taxonomy 로드 시 기본 Subtopic을 자동 선택한다. 따라서 `selectedSubtopicID == nil`만으로 초기 화면을 결정하면 첫 렌더에서 Keyword 모드가 바로 표시된다.

이 충돌은 아래 둘 중 하나로 해결한다.

권장안:
- View 전용 상태로 `hasUserSelectedSubtopic`을 둔다.
- 자동 선택된 Subtopic은 summary row/keyword 모드 진입 조건으로 보지 않는다.
- 사용자가 Subtopic chip을 클릭한 뒤에만 `hasUserSelectedSubtopic = true`로 설정하고 `.keywords`로 전환한다.

대안:
- ViewModel의 자동 Subtopic 선택을 제거하고 초기 `selectedSubtopicID`를 nil로 허용한다.
- 이 경우 prompt assembly와 기존 테스트 영향이 더 크므로 별도 회귀 테스트가 필요하다.

## 5. 레이아웃 규칙

전체 화면 구조:

```text
┌──────────────────────────────────────────┐
│ Draft                                    │ fixed 180pt
├──────────────────────────────────────────┤
│ Selection                                │ remaining height
├──────────────────────────────────────────┤
│ ActionBar                                │ intrinsic height
└──────────────────────────────────────────┘
```

Selection panel:
- `frame(maxHeight: .infinity)`로 남은 높이를 받는다.
- panel 내부에만 `ScrollView`를 둔다.
- 패널 radius는 design-system의 `CornerRadius.card` 값인 10pt를 사용한다.
- chip radius는 design-system의 `CornerRadius.chip` 값인 8pt를 사용한다.
- panel padding은 design-system의 `Spacing.md` 값인 16pt를 기본으로 사용한다.
- row 내부의 작은 간격은 `Spacing.sm` 값인 12pt를 기본으로 사용하고, chip wrapping 간격은 8pt를 사용한다.

Keyword group row:
- 그룹명은 왼쪽 고정 폭 84-100pt.
- chips는 오른쪽에서 wrapping한다.
- row 간격은 14-16pt.
- chip 간격은 horizontal/vertical 8pt.

예시:

```text
작업 대상   [Swift] [SwiftUI] [ViewModel] [API]
우선순위     [안정성] [단순성] [성능]
```

## 6. 컴포넌트 계획

### 6.1 새 컴포넌트: `SelectionPanelView`

위치:
- `floatingboard/Presentation/PromptBuilder/SelectionPanelView.swift`

책임:
- Selection step 상태 보유
- 자동 선택된 Subtopic과 사용자 명시 선택을 구분
- Subtopic 선택 모드와 Keyword 선택 모드 전환
- summary row 렌더링
- Topic display 위치를 명확히 유지

입력:
```swift
let topics: [Topic]
let selectedTopicID: TopicID
let subtopics: [Subtopic]
let selectedSubtopicID: String?
let visibleKeywordGroups: [KeywordGroup]
let keywordsForGroup: (String) -> [KeywordOption]
let isSelected: (String) -> Bool
let selectedKeywordTitles: [String]
let onSelectSubtopic: (String) -> Void
let onToggleKeyword: (String) -> Void
```

Topic 처리:
- MVP에서는 topic이 사실상 단일 값이므로 독립 선택 화면을 만들지 않는다.
- `TopicSelectorView`를 유지해야 한다면 `SelectionPanelView` 상단에 compact topic row로 배치한다.
- 단일 topic만 존재하면 `CompactTopicPillView`처럼 읽기 전용 pill로 표시하고 selection flow에는 포함하지 않는다.

### 6.2 `PromptBuilderView`

현재 `selectionDisclosure`를 제거하고 아래처럼 단순화한다.

```swift
VStack(alignment: .leading, spacing: 14) {
    PromptDraftEditorView(text: $viewModel.userDraftText)

    SelectionPanelView(
        topics: viewModel.topics,
        selectedTopicID: viewModel.selectedTopicID,
        subtopics: viewModel.subtopics,
        selectedSubtopicID: viewModel.selectedSubtopicID,
        visibleKeywordGroups: viewModel.visibleKeywordGroups,
        keywordsForGroup: viewModel.keywords(for:),
        isSelected: viewModel.isSelected(_:),
        selectedKeywordTitles: selectedKeywordTitles,
        onSelectSubtopic: viewModel.selectSubtopic,
        onToggleKeyword: viewModel.toggleKeyword(_:)
    )

    ActionBarView(...)
}
```

### 6.3 `SubtopicSelectorView`

유지하되 title 렌더링은 `SelectionPanelView`에서 제어한다. 필요하면 `showsTitle: Bool` 옵션을 추가한다.

Subtopic 선택 화면에서는 title을 표시한다. Keyword 모드에서는 Subtopic 목록이 숨겨지고 summary row만 표시된다.

### 6.4 `KeywordPickerView`

현재 `KeywordPickerView`는 이미 `WrappingHStack`을 사용한다. 변경의 핵심은 `WrappingHStack` 도입이 아니라, group title을 상단 섹션 헤더에서 좌측 고정 폭 라벨로 재배치하는 것이다.

```swift
HStack(alignment: .top, spacing: 12) {
    Text(group.title)
        .frame(width: 92, alignment: .leading)

    WrappingHStack(horizontalSpacing: 8, verticalSpacing: 8) {
        ...
    }
}
```

## 7. Interaction Details

Subtopic summary row:
- 왼쪽: selected subtopic title
- 중간 또는 보조 텍스트: selected keyword count
- 선택된 keyword가 있으면 최대 2개 keyword title 표시
- 오른쪽: chevron right icon
- hover 또는 pressed 상태는 macOS 기본 Button feedback 정도로 충분하다.
- row height는 32-36pt.

Keyword selection:
- selected chip은 checkmark + accent tinted background.
- unselected chip은 muted background.
- 선택된 overflow keyword는 collapsed 상태에서도 유지 표시한다.

More behavior:
- 1차 구현에서는 기존 global `More`를 유지해도 된다.
- 확장/축소 상태 모두 동일한 `label-left + chips-right` row layout을 사용한다.
- 축소 상태의 selected overflow keyword 유지 로직은 보존한다.
- 2차 개선에서는 그룹별 More가 더 적합하다.

Localization:
- 신규 파일인 `SelectionPanelView.swift`에 추가되는 사용자 대면 문자열은 처음부터 `String(localized:)` 또는 SwiftUI `Text("key")`로 작성한다.
- 기존 파일의 하드코딩 문자열은 이번 변경 범위에서 새로 추가하거나 이동하는 경우 함께 정리한다.

## 8. 구현 순서

1. `SelectionPanelView.swift` 추가
2. 자동 선택된 Subtopic과 사용자 명시 선택을 구분하는 view-only 상태 추가
3. `PromptBuilderView`에서 `selectionDisclosure` 제거
4. `TopicSelectorView`/`CompactTopicPillView` 배치 정책 정리
5. `KeywordPickerView`를 group title left-label row layout으로 변경
6. `SubtopicSelectorView` title 중복 여부 정리
7. 신규 사용자 대면 문자열 localization 적용
8. 빌드 검증

검증 명령:

```bash
xcodebuild -scheme floatingboard -destination 'platform=macOS' build
```

## 9. 완료 기준

- Draft는 고정 180pt로 유지된다.
- Selection은 기본적으로 보이며 접이식 disclosure가 아니다.
- 초기 진입 시 자동 선택된 Subtopic이 있더라도 Subtopic 선택 화면이 먼저 보인다.
- Subtopic 선택 후 Subtopic 목록은 한 줄 summary로 접힌다.
- summary row 클릭 시 Subtopic 선택 화면으로 돌아간다.
- summary row에는 Subtopic 제목과 keyword 선택 개수가 표시된다.
- Keyword groups는 label + chips row 구조로 읽힌다.
- More 확장/축소 후에도 row layout과 selected overflow keyword 표시가 유지된다.
- 신규 사용자 대면 문자열은 localization API를 사용한다.
- 빌드가 성공한다.

## 10. 남은 리스크

- 기존 SwiftUI 코드에는 하드코딩 문자열이 남아 있다. 신규 Selection UI에서 추가되는 문자열은 localization API를 사용하되, 전체 문자열 정리는 별도 작업으로 남긴다.
- 실제 패널 크기에서 chip wrapping이 과밀하면 group label width를 줄이거나 panel width/height를 다시 조정해야 한다.
- Taxonomy의 visible keyword 수가 많은 subtopic은 여전히 스크롤이 필요하다.
- View 전용 `hasUserSelectedSubtopic` 상태는 세션 내 UI 상태다. 패널 재생성/상태 복원 정책이 바뀌면 초기 진입 동작을 다시 확인해야 한다.
