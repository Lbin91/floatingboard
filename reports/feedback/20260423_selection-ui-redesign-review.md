# Selection UI Redesign Plan — 문서 리뷰 피드백

**대상 문서**: `docs/selection-ui-redesign-plan.md`
**리뷰 일시**: 2026-04-23
**이슈 수**: 8건 (Medium 1, Low 7)

---

## Medium

### 1. "Preview 숨김" 목표가 실제 코드와 불일치

**문서 위치**: Section 1, Section 9

Plan은 *"Preview는 현재 화면에서 숨긴 상태를 유지하고"* 라고 기술하고, Section 9 완료 기준에 *"Preview가 보이지 않는다"* 를 포함.

그러나 `PromptPreviewView`는 현재 `PromptBuilderView` 및 다른 어떤 뷰에서도 참조되지 않음. 이미 뷰 계층에서 제거된 상태이며, LLM 상태 표시는 `ActionBarView`의 인라인 배지로 대체되어 있음.

**위험**: 구현자가 존재하지 않는 Preview를 찾아 제거하려다 시간 낭비.

**권장**: Section 1에서 "Preview 숨김" 목표를 제거하거나, "Preview는 이미 미사용 상태이므로 별도 조치 불필요"로 수정. Section 9 완료 기준에서도 해당 항목 삭제.

---

## Low

### 2. `TopicSelectorView` 배치 위치 누락

**문서 위치**: Section 6.1, 6.2, 6.3

Section 6.2의 통합 스니펫은 `Draft → Selection → ActionBar` 구조만 보여줌. `TopicSelectorView`가 새 레이아웃에서 어디에 위치하는지 명시되지 않음.

현재 코드에서 `TopicSelectorView`는 `PromptBuilderView` 내 `TopicSelector` 섹션에 독립적으로 존재. Plan의 `SelectionPanelView`가 서브토픽 + 키워드만 담당한다면, 토픽 셀렉터는 `SelectionPanelView` 외부에 유지되어야 함을 명시적으로 기술 필요.

**권장**: Section 6.2에 `TopicSelectorView`의 배치를 명시. 예: `"TopicSelectorView는 SelectionPanelView 상단에 PromptBuilderView 레벨에서 유지"`.

### 3. 서브토픽 자동 선택이 드릴다운 UX와 충돌

**문서 위치**: Section 4

Plan은 `SelectionStep` 상태 모델을 제안:

```swift
private enum SelectionStep {
    case subtopic
    case keywords
}
```

규칙: `selectedSubtopicID == nil` → 항상 `.subtopic`.

그러나 현재 `PromptBuilderViewModel`은 `refreshSubtopics()` (line 388)에서 taxonomy 로드 시 기본 서브토픽을 자동 선택:

```swift
let defaultSubtopicID = taxonomy.topic(id: selectedTopicID)?.defaultSubtopicID
let nextSubtopicID = defaultSubtopicID ?? subtopics.first?.id
```

결과적으로 `selectedSubtopicID`가 거의 `nil`이 아니며, 첫 렌더 시 사용자가 서브토픽 그리드가 아닌 키워드 뷰를 바로 보게 됨. 드릴다운 UX가 의도대로 동작하지 않음.

**권장**: 두 가지 옵션 중 선택 명시:
- (a) ViewModel의 자동 선택 로직 제거 (초기 진입 시 `.subtopic` 단계 표시)
- (b) 자동 선택 vs 사용자 명시 선택을 구분하는 플래그 추가 (`isSubtopicExplicitlySelected`)

### 4. `WrappingHStack` 도입으로 서술되었으나 이미 존재

**문서 위치**: Section 6.4

Plan은 `KeywordPickerView`를 "vertical group stack"에서 `WrappingHStack` row 레이아웃으로 변경한다고 서술. 그러나 현재 `KeywordPickerView`는 이미 `WrappingHStack`을 사용 중.

실제 변경 내용은 group title을 세로 섹션 헤더에서 좌측 고정 폭 라벨로 이동하는 것:

```swift
HStack(alignment: .top, spacing: 12) {
    Text(group.title)
        .frame(width: 92, alignment: .leading)
    WrappingHStack(...)
}
```

**권장**: 서술을 "`WrappingHStack` 도입"에서 "group title을 상단 헤더에서 좌측 라벨로 재배치"로 수정.

### 5. 키워드 개수 요약 행 누락

**문서 위치**: Section 6.2, Section 7

현재 `selectionDisclosure`의 `selectionSummary` (lines 99–122 of `PromptBuilderView`)는 선택된 서브토픽 제목, 키워드 개수, 최대 2개 키워드 이름을 표시.

Plan의 Section 7 summary row는 서브토픽 제목 + chevron만 설명. 키워드 개수 요약이 새 디자인에 반영되지 않음.

**권장**: 의도적인 단순화인지 명시. 유지하려면 summary row에 키워드 개수 포함 설계 추가.

### 6. `More` 확장 토글과 새 레이아웃의 상호작용 미정의

**문서 위치**: Section 7

현재 `KeywordPickerView`는 정교한 확장 시스템 사용:
- 축소 시 첫 2개 그룹만 표시
- 그룹당 `collapsedKeywordLimit` 키워드 표시
- 축소 상태에서도 선택된 오버플로우 키워드 유지 (`selectedOverflow` 로직)

새 row 레이아웃에서 `More` 클릭 시 추가 그룹이 나타날 때도 label-left + chips-right 패턴을 따르는지 명시되지 않음.

**권장**: 확장/축소 시에도 동일한 row 레이아웃 패턴이 적용됨을 명시.

### 7. 새 파일에 `String(localized:)` 사용 권장

**문서 위치**: Section 10

Plan은 localization을 후순위로 미룸. 그러나 프로젝트 컨벤션(`AGENTS.md`)은 모든 사용자 대면 문자열을 `Localizable.xcstrings`로 관리하도록 요구.

새로 생성되는 `SelectionPanelView`는 레거시 제약이 없으므로, `"Selection"`, `"Subtopic"`, `"Draft"` 등의 문자열을 처음부터 `String(localized:)`로 작성하는 것이 재작업 비용을 줄임.

**권장**: Section 10에 *"신규 파일은 `String(localized:)` 사용"* 명시.

### 8. 레이아웃 값이 design-system 토큰과 충돌

**문서 위치**: Section 5

Plan 명시값 vs `design-system.md` 토큰:

| 항목 | Plan 값 | Design Token |
|------|---------|-------------|
| Card radius | 8pt | `CornerRadius.chip = 8`, `CornerRadius.card = 10` |
| Padding (h) | 14–16pt | `Spacing.sm = 12`, `Spacing.md = 16` |
| Padding (v) | 12–14pt | `Spacing.sm = 12`, `Spacing.md = 16` |

`SelectionPanelView`는 패널 수준 요소이므로 `CornerRadius.card (10)`이 더 적합. 패딩 범위도 토큰 값 사이에 위치.

**권장**: design-system 토큰을 직접 참조하도록 수정. 예: `"padding: Spacing.md (16pt)"`, `"radius: CornerRadius.card (10pt)"`.

---

## 요약

| 심각도 | 건수 | 주요 내용 |
|--------|------|----------|
| Medium | 1 | 존재하지 않는 Preview 숨김 목표 |
| Low | 7 | 누락된 명세, 부정확한 서술, 토큰 불일치 |

코드 버그는 없음. 구현 착수 전 **Issue 1**(Preview 서술 수정), **Issue 3**(자동 선택 로직 충돌 해결)을 우선 보완 권장.
