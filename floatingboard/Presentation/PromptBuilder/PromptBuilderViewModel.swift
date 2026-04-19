import Foundation
import Observation

@MainActor
@Observable
final class PromptBuilderViewModel {
    private let taxonomyRepository: TaxonomyRepository
    private let buildPromptUseCase: BuildPromptUseCase
    private let clipboardManager: ClipboardManager

    private(set) var taxonomy: PromptTaxonomy?
    private(set) var topics: [Topic] = []
    private(set) var subtopics: [Subtopic] = []
    private(set) var previewText: String = ""
    private(set) var errorMessage: String?

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

    init(
        taxonomyRepository: TaxonomyRepository,
        buildPromptUseCase: BuildPromptUseCase,
        clipboardManager: ClipboardManager
    ) {
        self.taxonomyRepository = taxonomyRepository
        self.buildPromptUseCase = buildPromptUseCase
        self.clipboardManager = clipboardManager
        loadTaxonomy()
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
            previewText = ""
            return
        }

        let composition = buildPromptUseCase.execute(
            draft: PromptDraft(
                topicID: selectedTopicID,
                subtopicID: selectedSubtopicID,
                selectedKeywordIDs: selectedKeywordIDs,
                userInput: userDraftText
            ),
            taxonomy: taxonomy
        )

        previewText = composition.renderedText
    }
}
