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
    func switchingToEditModeSeedsEditablePromptFromGeneratedPrompt() throws {
        let viewModel = makeViewModel()
        let generatedPreview = viewModel.previewText

        viewModel.switchToEditMode()

        #expect(viewModel.previewMode == .edited)
        #expect(viewModel.editedPromptText == generatedPreview)
    }

    @Test
    func editingPromptMarksEditedStateAsDirty() throws {
        let viewModel = makeViewModel()

        viewModel.switchToEditMode()
        viewModel.editedPromptText = "Manual override text"

        #expect(viewModel.generatedPrompt.isEditedDirty)
        #expect(viewModel.previewText == "Manual override text")
    }

    @Test
    func selectionChangesKeepEditedPromptAndMarkItOutdated() throws {
        let viewModel = makeViewModel()

        viewModel.switchToEditMode()
        viewModel.editedPromptText = "Edited prompt"
        viewModel.selectSubtopic("bugfix")

        #expect(viewModel.editedPromptText == "Edited prompt")
        #expect(viewModel.generatedPrompt.isEditedOutdated)
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

    @Test
    func saveAndRestoreDraftPreservesSelections() throws {
        let suiteName = "test-save-restore-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        suite.removePersistentDomain(forName: suiteName)
        defer { suite.removePersistentDomain(forName: suiteName) }

        let draftRepo = LocalPromptDraftRepository(defaults: suite)

        let viewModel1 = makeViewModel(draftRepository: draftRepo)
        viewModel1.selectSubtopic("refactor")
        viewModel1.toggleKeyword("performance")
        viewModel1.userDraftText = "My saved draft"
        viewModel1.saveDraft()

        let viewModel2 = makeViewModel(draftRepository: draftRepo)

        #expect(viewModel2.selectedSubtopicID == "refactor")
        #expect(viewModel2.isSelected("performance"))
        #expect(viewModel2.userDraftText == "My saved draft")
    }

    @Test
    func saveAndRestoreEditedPrompt() throws {
        let suite = UserDefaults(suiteName: "test-save-edited")!
        suite.removePersistentDomain(forName: "test-save-edited")
        defer { suite.removePersistentDomain(forName: "test-save-edited") }

        let draftRepo = LocalPromptDraftRepository(defaults: suite)

        let viewModel1 = makeViewModel(draftRepository: draftRepo)
        viewModel1.switchToEditMode()
        viewModel1.editedPromptText = "Custom edited prompt"
        viewModel1.saveDraft()

        let viewModel2 = makeViewModel(draftRepository: draftRepo)

        #expect(viewModel2.previewMode == .edited)
        #expect(viewModel2.generatedPrompt.hasEditableDraft)
        #expect(viewModel2.editedPromptText == "Custom edited prompt")
    }

    @Test
    func restoreWithNoSavedDraftUsesDefaults() throws {
        let suite = UserDefaults(suiteName: "test-empty-restore")!
        suite.removePersistentDomain(forName: "test-empty-restore")
        defer { suite.removePersistentDomain(forName: "test-empty-restore") }

        let draftRepo = LocalPromptDraftRepository(defaults: suite)

        let viewModel = makeViewModel(draftRepository: draftRepo)

        #expect(viewModel.selectedTopicID == .coding)
        #expect(viewModel.selectedSubtopicID == "implementation")
        #expect(viewModel.previewMode == .generated)
    }

    @Test
    func clearDraftRemovesSavedState() throws {
        let suite = UserDefaults(suiteName: "test-clear")!
        suite.removePersistentDomain(forName: "test-clear")
        defer { suite.removePersistentDomain(forName: "test-clear") }

        let draftRepo = LocalPromptDraftRepository(defaults: suite)

        let viewModel = makeViewModel(draftRepository: draftRepo)
        viewModel.userDraftText = "Will be cleared"
        viewModel.saveDraft()

        try draftRepo.clearDraft()

        let restored = try draftRepo.loadDraft()
        #expect(restored == nil)
    }

    private func makeViewModel(draftRepository: PromptDraftRepository? = nil) -> PromptBuilderViewModel {
        let repository = LocalTaxonomyRepository(resourceURL: taxonomyURL())
        let repo = draftRepository ?? LocalPromptDraftRepository(defaults: isolatedDefaults())
        let keychainRepo = KeychainRepositoryImpl()
        let openRouter = OpenRouterRepository()
        let ollama = OllamaRepository()
        let provider = AIRepositoryProvider(openRouter: openRouter, ollama: ollama)
        return PromptBuilderViewModel(
            taxonomyRepository: repository,
            buildPromptUseCase: BuildPromptUseCase(),
            clipboardManager: ClipboardManager(),
            draftRepository: repo,
            keychainRepository: keychainRepo,
            refinePromptUseCase: RefinePromptUseCase(provider: provider),
            translatePromptUseCase: TranslatePromptUseCase(provider: provider)
        )
    }

    private func isolatedDefaults(name: String = "test-isolated-\(UUID().uuidString)") -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    private func taxonomyURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "floatingboard/Resources/PromptTaxonomy/coding.json")
    }
}
