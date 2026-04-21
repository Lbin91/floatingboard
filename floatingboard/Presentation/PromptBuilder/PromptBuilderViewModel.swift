import Foundation
import Observation

@MainActor
@Observable
final class PromptBuilderViewModel {
    private let taxonomyRepository: TaxonomyRepository
    private let buildPromptUseCase: BuildPromptUseCase
    private let clipboardManager: ClipboardManager
    private let draftRepository: PromptDraftRepository

    private(set) var taxonomy: PromptTaxonomy?
    private(set) var topics: [Topic] = []
    private(set) var subtopics: [Subtopic] = []
    private(set) var errorMessage: String?
    private(set) var copyFeedbackMessage: String?
    private(set) var generatedPrompt = GeneratedPrompt()
    private(set) var previewMode: PromptPreviewMode = .generated

    var selectedTopicID: TopicID = .coding {
        didSet { refreshSubtopics() }
    }

    var selectedSubtopicID: String? {
        didSet { handleSubtopicChange() }
    }

    var selectedKeywordIDs: [String] = [] {
        didSet { rebuildPreview() }
    }

    var userDraftText: String = "" {
        didSet { rebuildPreview() }
    }

    var editedPromptText: String {
        get { generatedPrompt.displayedEditedText }
        set {
            generatedPrompt.editedText = newValue
            generatedPrompt.hasEditableDraft = true
            generatedPrompt.isEditedDirty = newValue != generatedPrompt.baseText
            generatedPrompt.isEditedOutdated = newValue != generatedPrompt.baseText
        }
    }

    var previewText: String {
        switch previewMode {
        case .generated:
            return generatedPrompt.displayedGeneratedText
        case .edited:
            return generatedPrompt.displayedEditedText
        }
    }

    init(
        taxonomyRepository: TaxonomyRepository,
        buildPromptUseCase: BuildPromptUseCase,
        clipboardManager: ClipboardManager,
        draftRepository: PromptDraftRepository
    ) {
        self.taxonomyRepository = taxonomyRepository
        self.buildPromptUseCase = buildPromptUseCase
        self.clipboardManager = clipboardManager
        self.draftRepository = draftRepository
        loadTaxonomy()
        restoreDraft()
    }

    var visibleKeywordGroups: [KeywordGroup] {
        guard let taxonomy, let selectedSubtopicID else { return [] }
        let visibleIDs = taxonomy.visibilityRule(for: selectedSubtopicID)?.visibleGroupIDs ?? []

        return visibleIDs.compactMap { id in
            taxonomy.keywordGroups.first { $0.id == id }
        }
    }

    func keywords(for groupID: String) -> [KeywordOption] {
        guard let taxonomy, let selectedSubtopicID else { return [] }

        let visibleKeywordIDs = taxonomy.visibilityRule(for: selectedSubtopicID)?.visibleKeywordIDs ?? []

        return visibleKeywordIDs.compactMap { keywordID in
            guard let keyword = taxonomy.keyword(id: keywordID), keyword.groupID == groupID else {
                return nil
            }
            return keyword
        }
    }

    func isSelected(_ keywordID: String) -> Bool {
        selectedKeywordIDs.contains(keywordID)
    }

    func selectTopic(_ topicID: TopicID) {
        selectedTopicID = topicID
    }

    func selectSubtopic(_ subtopicID: String) {
        selectedSubtopicID = subtopicID
    }

    func toggleKeyword(_ keywordID: String) {
        if let index = selectedKeywordIDs.firstIndex(of: keywordID) {
            selectedKeywordIDs.remove(at: index)
        } else {
            selectedKeywordIDs.append(keywordID)
        }
    }

    func copyPreview() {
        guard !previewText.isEmpty else { return }
        clipboardManager.copy(previewText)
        copyFeedbackMessage = "Copied to clipboard"

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            if copyFeedbackMessage == "Copied to clipboard" {
                copyFeedbackMessage = nil
            }
        }
    }

    func switchToGeneratedMode() {
        previewMode = .generated
    }

    func switchToEditMode() {
        if !generatedPrompt.hasEditableDraft {
            generatedPrompt.editedText = generatedPrompt.baseText
            generatedPrompt.hasEditableDraft = true
            generatedPrompt.isEditedDirty = false
            generatedPrompt.isEditedOutdated = false
        }

        previewMode = .edited
    }

    func regenerateFromSelections() {
        generatedPrompt.editedText = generatedPrompt.baseText
        generatedPrompt.hasEditableDraft = false
        generatedPrompt.isEditedDirty = false
        generatedPrompt.isEditedOutdated = false
        previewMode = .generated
    }

    func saveDraft() {
        let draft = PromptDraft(
            topicID: selectedTopicID,
            subtopicID: selectedSubtopicID,
            selectedKeywordIDs: selectedKeywordIDs,
            userInput: userDraftText
        )
        try? draftRepository.saveDraft(draft, editedPrompt: generatedPrompt.hasEditableDraft ? generatedPrompt : nil)
    }

    func restoreDraft() {
        guard let restored = try? draftRepository.loadDraft() else { return }

        let draft = restored.draft

        selectedTopicID = draft.topicID

        if let subtopicID = draft.subtopicID {
            selectedSubtopicID = subtopicID
        }

        selectedKeywordIDs = draft.selectedKeywordIDs
        userDraftText = draft.userInput

        if let editedPrompt = restored.editedPrompt {
            generatedPrompt = editedPrompt
            previewMode = .edited
        }
    }

    private func loadTaxonomy() {
        do {
            let taxonomy = try taxonomyRepository.loadTaxonomy()
            self.taxonomy = taxonomy
            self.topics = taxonomy.topics.sorted { $0.sortOrder < $1.sortOrder }
            self.selectedTopicID = topics.first?.id ?? .coding
            refreshSubtopics()
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load taxonomy: \(error)"
        }
    }

    private func refreshSubtopics() {
        guard let taxonomy else {
            subtopics = []
            selectedSubtopicID = nil
            return
        }

        subtopics = taxonomy.subtopics.filter { $0.topicID == selectedTopicID }
        let defaultSubtopicID = taxonomy.topic(id: selectedTopicID)?.defaultSubtopicID
        let nextSubtopicID = defaultSubtopicID ?? subtopics.first?.id

        if selectedSubtopicID != nextSubtopicID {
            selectedSubtopicID = nextSubtopicID
        } else {
            handleSubtopicChange()
        }
    }

    private func handleSubtopicChange() {
        guard let taxonomy, let selectedSubtopicID, let subtopic = taxonomy.subtopic(id: selectedSubtopicID) else {
            selectedKeywordIDs = []
            rebuildPreview()
            return
        }

        let visibleKeywordIDs = Set(taxonomy.visibilityRule(for: selectedSubtopicID)?.visibleKeywordIDs ?? [])
        selectedKeywordIDs = subtopic.defaultKeywordIDs.filter { visibleKeywordIDs.contains($0) }
        rebuildPreview()
    }

    private func rebuildPreview() {
        guard let taxonomy else {
            generatedPrompt = GeneratedPrompt()
            return
        }

        copyFeedbackMessage = nil
        let previousBaseText = generatedPrompt.baseText

        let composition = buildPromptUseCase.execute(
            draft: PromptDraft(
                topicID: selectedTopicID,
                subtopicID: selectedSubtopicID,
                selectedKeywordIDs: selectedKeywordIDs,
                userInput: userDraftText
            ),
            taxonomy: taxonomy
        )

        let nextBaseText = composition.renderedText
        let baseChanged = previousBaseText != nextBaseText
        generatedPrompt.baseText = nextBaseText

        if generatedPrompt.hasEditableDraft {
            if generatedPrompt.editedText.isEmpty {
                generatedPrompt.editedText = previousBaseText
            }

            generatedPrompt.isEditedDirty = generatedPrompt.editedText != generatedPrompt.baseText
            generatedPrompt.isEditedOutdated = generatedPrompt.isEditedOutdated || baseChanged
        } else {
            generatedPrompt.editedText = generatedPrompt.baseText
            generatedPrompt.isEditedDirty = false
            generatedPrompt.isEditedOutdated = false
        }
    }
}
