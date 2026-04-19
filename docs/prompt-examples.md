# Prompt Examples Draft

이 문서는 [`coding.json`](./coding.json) 초안을 검증하기 위한 샘플 세트다.  
목적은 "구조가 맞는가"를 보는 것이지, 문장을 최종 확정하는 것이 아니다.

## Example 1: 오류 개선

### 선택값
- 대주제: `코딩`
- 소주제: `오류 개선`
- 키워드:
  - `Swift`
  - `최소 수정`
  - `기존 스타일 유지`
  - `원인 분석 먼저`
  - `회귀 테스트 추가`
  - `diff 중심`

### 유저 초안

```text
SwiftUI 설정 화면에서 API 키 저장 후 앱 재실행 시 값이 비어 보이는 문제가 있다.
원인을 먼저 파악하고 최소 수정으로 고치고 싶다.
```

### 기대 Base Prompt 예시

```text
Current Situation:
The work happens in a Swift codebase.

Task Type:
Bug fixing and issue improvement.

Constraints:
Keep the change set minimal and localized.
Preserve the existing coding style and local patterns.

Expected Output:
Present the result in a diff-oriented or change-focused way.

Verification Requirements:
Explain the root cause before proposing the fix.
Add or propose a regression test to prevent the issue from returning.

User Draft:
SwiftUI 설정 화면에서 API 키 저장 후 앱 재실행 시 값이 비어 보이는 문제가 있다.
원인을 먼저 파악하고 최소 수정으로 고치고 싶다.

Final Instruction:
Investigate the issue, explain the root cause first, and produce a focused bugfix prompt with minimal change scope and regression protection.
```

### 검증 포인트
- `priority`가 없어도 프롬프트가 어색하지 않아야 함
- `verification` 슬롯이 bugfix에서 강하게 작동해야 함
- 문장이 너무 길어지지 않아야 함

## Example 2: 리팩토링 작업

### 선택값
- 대주제: `코딩`
- 소주제: `리팩토링 작업`
- 키워드:
  - `가독성`
  - `유지보수성`
  - `최소 수정`
  - `기존 동작 보존`
  - `diff 중심`

### 유저 초안

```text
설정 화면 view model이 네트워크 상태, 입력값 검증, 저장 로직을 모두 들고 있어서 너무 비대해졌다.
동작은 유지하면서 구조를 정리하고 싶다.
```

### 기대 Base Prompt 예시

```text
Current Situation:
The request is about a refactoring task in an existing codebase.

Task Type:
Refactoring work with behavior preservation.

Focus / Priorities:
Prioritize readability and clarity.
Prioritize maintainability and long-term simplicity.

Constraints:
Keep the change set minimal and localized.

Expected Output:
Present the result in a diff-oriented or change-focused way.

Verification Requirements:
Make behavior preservation explicit and identify what must not change.

User Draft:
설정 화면 view model이 네트워크 상태, 입력값 검증, 저장 로직을 모두 들고 있어서 너무 비대해졌다.
동작은 유지하면서 구조를 정리하고 싶다.

Final Instruction:
Produce a refactoring-oriented prompt that improves structure and maintainability without changing observable behavior.
```

### 검증 포인트
- `리팩토링`에서는 `원인 분석 먼저` 같은 bugfix 전용 키워드가 나오지 않아야 함
- `verification`은 테스트보다 behavior preservation 쪽으로 기울어야 함

## Example 3: 최초 기획

### 선택값
- 대주제: `코딩`
- 소주제: `최초 기획`
- 키워드:
  - `API`
  - `UI`
  - `유지보수성`
  - `단계별 계획`
  - `체크리스트 포함`
  - `영향 범위 분석`

### 유저 초안

```text
구조화된 프롬프트 빌더에서 참고 문서를 프로젝트별로 연결하는 기능을 추가하려고 한다.
설정 방식과 UI 흐름, 이후 확장성을 함께 고려한 초기 기획안이 필요하다.
```

### 기대 Base Prompt 예시

```text
Current Situation:
The work affects API design, integration, or service logic.
The work affects user-facing UI behavior or structure.

Task Type:
Initial planning for a new feature or system direction.

Focus / Priorities:
Prioritize maintainability and long-term simplicity.

Expected Output:
Organize the answer as a step-by-step plan.
Include a concise checklist or completion criteria.

Verification Requirements:
Identify the likely impact area and downstream risks.

User Draft:
구조화된 프롬프트 빌더에서 참고 문서를 프로젝트별로 연결하는 기능을 추가하려고 한다.
설정 방식과 UI 흐름, 이후 확장성을 함께 고려한 초기 기획안이 필요하다.

Final Instruction:
Produce a practical first-pass planning prompt for the feature, including scope, flow, impact analysis, and maintainable extension points.
```

### 검증 포인트
- planning 계열은 `constraints` 없이도 성립 가능해야 함
- implementation 계열처럼 코드 출력을 강하게 요구하지 않아야 함
- 영향 범위 분석이 자연스럽게 들어가야 함

## Usage Notes

- 이 예시 문서는 실제 UI 동작과 함께 빠르게 검증하는 용도다
- 구현 전에는 `base prompt` 품질 검토용으로 사용
- 구현 후에는 golden snapshot 테스트의 텍스트 기준으로 재사용 가능
