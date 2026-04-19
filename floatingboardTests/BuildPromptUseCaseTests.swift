import Foundation
import Testing
@testable import floatingboard

struct BuildPromptUseCaseTests {
    @Test
    func loadsTaxonomyFromJSON() throws {
        let repository = LocalTaxonomyRepository(resourceURL: taxonomyURL())
        let taxonomy = try repository.loadTaxonomy()

        #expect(taxonomy.topics.count == 1)
        #expect(taxonomy.subtopics.count == 8)
        #expect(taxonomy.keywords.count == 28)
    }

    @Test
    func buildsBugfixPromptComposition() throws {
        let repository = LocalTaxonomyRepository(resourceURL: taxonomyURL())
        let taxonomy = try repository.loadTaxonomy()
        let useCase = BuildPromptUseCase()

        let draft = PromptDraft(
            topicID: .coding,
            subtopicID: "bugfix",
            selectedKeywordIDs: [
                "swift",
                "minimal-change",
                "preserve-style",
                "root-cause-first",
                "add-regression-test",
                "diff-first"
            ],
            userInput: """
            SwiftUI settings screen loses the saved API key after relaunch.
            Find the root cause and fix it with minimal change.
            """
        )

        let composition = useCase.execute(draft: draft, taxonomy: taxonomy)
        let rendered = composition.renderedText

        #expect(rendered.contains("Current Situation:"))
        #expect(rendered.contains("Task Type:\nBug fixing and issue improvement."))
        #expect(rendered.contains("Constraints:"))
        #expect(rendered.contains("Verification Requirements:"))
        #expect(rendered.contains("Final Instruction:"))
    }

    private func taxonomyURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "floatingboard/Resources/PromptTaxonomy/coding.json")
    }
}
