import AppKit
import Foundation
import Testing
@testable import floatingboard

@MainActor
struct PromptBuilderViewModelTests {
    @Test
    func initializesWithCodingTopicAndDefaultSubtopic() throws {
        let viewModel = makeViewModel()

        #expect(viewModel.selectedTopicID == .coding)
        #expect(viewModel.selectedSubtopicID == "implementation")
        #expect(!viewModel.subtopics.isEmpty)
        #expect(!viewModel.visibleKeywordGroups.isEmpty)
        #expect(!viewModel.previewText.isEmpty)
    }

    @Test
    func changingSubtopicRecomputesKeywordsAndPreview() throws {
        let viewModel = makeViewModel()
        let initialPreview = viewModel.previewText

        viewModel.selectSubtopic("bugfix")

        #expect(viewModel.selectedSubtopicID == "bugfix")
        #expect(viewModel.isSelected("root-cause-first"))
        #expect(viewModel.previewText.contains("Bug fixing and issue improvement."))
        #expect(viewModel.previewText != initialPreview)
    }

    @Test
    func togglingKeywordUpdatesPreview() throws {
        let viewModel = makeViewModel()
        viewModel.selectSubtopic("refactor")

        let before = viewModel.previewText
        viewModel.toggleKeyword("performance")
        let after = viewModel.previewText

        #expect(after != before)
        #expect(after.contains("Prioritize runtime performance and efficiency."))
    }

    @Test
    func editingDraftUpdatesPreview() throws {
        let viewModel = makeViewModel()

        viewModel.selectSubtopic("initial-planning")
        viewModel.userDraftText = "Design the first version of a project-scoped reference document feature."

        #expect(viewModel.previewText.contains("User Draft:"))
        #expect(viewModel.previewText.contains("project-scoped reference document feature"))
    }

    @Test
    func copyPreviewWritesToClipboardAndShowsFeedback() throws {
        let viewModel = makeViewModel()
        viewModel.userDraftText = "Clipboard verification draft"

        viewModel.copyPreview()

        let clipboardText = NSPasteboard.general.string(forType: .string)
        #expect(clipboardText == viewModel.previewText)
        #expect(viewModel.copyFeedbackMessage == "Copied to clipboard")
    }

    private func makeViewModel() -> PromptBuilderViewModel {
        let repository = LocalTaxonomyRepository(resourceURL: taxonomyURL())
        return PromptBuilderViewModel(
            taxonomyRepository: repository,
            buildPromptUseCase: BuildPromptUseCase(),
            clipboardManager: ClipboardManager()
        )
    }

    private func taxonomyURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "floatingboard/Resources/PromptTaxonomy/coding.json")
    }
}
