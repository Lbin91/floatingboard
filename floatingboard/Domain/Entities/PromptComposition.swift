import Foundation

struct PromptComposition: Equatable {
    var currentSituation: [String] = []
    var taskType: String?
    var priorities: [String] = []
    var constraints: [String] = []
    var expectedOutput: [String] = []
    var verificationRequirements: [String] = []
    var userDraft: String?
    var references: [String] = []
    var finalInstruction: String?

    var renderedText: String {
        var sections: [String] = []

        func appendSection(title: String, lines: [String]) {
            guard !lines.isEmpty else { return }
            sections.append(title + ":\n" + lines.joined(separator: "\n"))
        }

        func appendSection(title: String, text: String?) {
            guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            sections.append(title + ":\n" + text)
        }

        appendSection(title: "Current Situation", lines: currentSituation)
        appendSection(title: "Task Type", text: taskType)
        appendSection(title: "Focus / Priorities", lines: priorities)
        appendSection(title: "Constraints", lines: constraints)
        appendSection(title: "Expected Output", lines: expectedOutput)
        appendSection(title: "Verification Requirements", lines: verificationRequirements)
        appendSection(title: "User Draft", text: userDraft)
        appendSection(title: "References", lines: references)
        appendSection(title: "Final Instruction", text: finalInstruction)

        return sections.joined(separator: "\n\n")
    }
}
