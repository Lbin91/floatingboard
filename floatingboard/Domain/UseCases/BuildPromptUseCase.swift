import Foundation

struct BuildPromptUseCase {
    func execute(draft: PromptDraft, taxonomy: PromptTaxonomy) -> PromptComposition {
        guard let subtopicID = draft.subtopicID,
              let subtopic = taxonomy.subtopic(id: subtopicID)
        else {
            return PromptComposition(userDraft: draft.userInput.isEmpty ? nil : draft.userInput)
        }

        let selectedKeywords = draft.selectedKeywordIDs.compactMap { taxonomy.keyword(id: $0) }

        var composition = PromptComposition()
        composition.taskType = taskTypePrompt(for: subtopicID)
        composition.finalInstruction = taxonomy.finalInstructionTemplate(for: subtopicID)
        composition.userDraft = draft.userInput.isEmpty ? nil : draft.userInput

        for keyword in selectedKeywords {
            switch keyword.type {
            case .context:
                composition.currentSituation.append(keyword.promptFragment)
            case .priority:
                composition.priorities.append(keyword.promptFragment)
            case .constraint:
                composition.constraints.append(keyword.promptFragment)
            case .output:
                composition.expectedOutput.append(keyword.promptFragment)
            case .verification:
                composition.verificationRequirements.append(keyword.promptFragment)
            }
        }

        let enabledSections = Set(subtopic.enabledSectionIDs)

        if !enabledSections.contains("situation") { composition.currentSituation = [] }
        if !enabledSections.contains("taskType") { composition.taskType = nil }
        if !enabledSections.contains("focus") { composition.priorities = [] }
        if !enabledSections.contains("constraints") { composition.constraints = [] }
        if !enabledSections.contains("expectedOutput") { composition.expectedOutput = [] }
        if !enabledSections.contains("verification") { composition.verificationRequirements = [] }
        if !enabledSections.contains("userDraft") { composition.userDraft = nil }
        if !enabledSections.contains("references") { composition.references = [] }
        if !enabledSections.contains("finalInstruction") { composition.finalInstruction = nil }

        return composition
    }

    private func taskTypePrompt(for subtopicID: String) -> String {
        switch subtopicID {
        case "initial-planning":
            return "Initial planning for a new feature or system direction."
        case "planning-revision":
            return "Revision planning for an existing feature, flow, or architecture direction."
        case "implementation":
            return "Implementation work for concrete product or code changes."
        case "refactor":
            return "Refactoring work with behavior preservation."
        case "bugfix":
            return "Bug fixing and issue improvement."
        case "testing":
            return "Testing work focused on validation, coverage, and confidence."
        case "feature-addition":
            return "Feature addition work in an existing product or codebase."
        case "feature-removal":
            return "Feature removal work with explicit scope and cleanup boundaries."
        default:
            return "Structured coding task."
        }
    }
}
