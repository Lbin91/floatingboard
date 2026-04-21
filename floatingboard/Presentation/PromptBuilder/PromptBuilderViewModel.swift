import CryptoKit
import Foundation
import Observation

@MainActor
@Observable
final class PromptBuilderViewModel {
    private let taxonomyRepository: TaxonomyRepository
    private let buildPromptUseCase: BuildPromptUseCase
    private let clipboardManager: ClipboardManager
    private let draftRepository: PromptDraftRepository
    private let keychainRepository: KeychainRepository
    private let refinePromptUseCase: RefinePromptUseCase
    private let translatePromptUseCase: TranslatePromptUseCase

    private(set) var taxonomy: PromptTaxonomy?
    private(set) var topics: [Topic] = []
    private(set) var subtopics: [Subtopic] = []
    private(set) var errorMessage: String?
    private(set) var copyFeedbackMessage: String?
    private(set) var generatedPrompt = GeneratedPrompt()
    private(set) var previewMode: PromptPreviewMode = .generated

    // MARK: - LLM State (Phase 3)

    private(set) var llmTaskState: LLMTaskState = .idle
    private(set) var refinedPrompt: String?
    private(set) var translatedPrompt: String?
    var activeModelConfig: LLMModelConfig?
    private var activeLLMTask: Task<Void, Never>?
    private var lastRefineFingerprint: String?
    private var lastTranslateFingerprint: String?

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
        case .refined:
            return refinedPrompt ?? generatedPrompt.displayedGeneratedText
        case .translated:
            return translatedPrompt ?? generatedPrompt.displayedGeneratedText
        }
    }

    init(
        taxonomyRepository: TaxonomyRepository,
        buildPromptUseCase: BuildPromptUseCase,
        clipboardManager: ClipboardManager,
        draftRepository: PromptDraftRepository,
        keychainRepository: KeychainRepository,
        refinePromptUseCase: RefinePromptUseCase,
        translatePromptUseCase: TranslatePromptUseCase
    ) {
        self.taxonomyRepository = taxonomyRepository
        self.buildPromptUseCase = buildPromptUseCase
        self.clipboardManager = clipboardManager
        self.draftRepository = draftRepository
        self.keychainRepository = keychainRepository
        self.refinePromptUseCase = refinePromptUseCase
        self.translatePromptUseCase = translatePromptUseCase
        loadTaxonomy()
        restoreDraft()
    }

    // MARK: - Taxonomy & Selection

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

    // MARK: - Preview Modes

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

    func switchToRefinedMode() {
        if refinedPrompt == nil { return }
        previewMode = .refined
    }

    func switchToTranslatedMode() {
        if translatedPrompt == nil { return }
        previewMode = .translated
    }

    func regenerateFromSelections() {
        generatedPrompt.editedText = generatedPrompt.baseText
        generatedPrompt.hasEditableDraft = false
        generatedPrompt.isEditedDirty = false
        generatedPrompt.isEditedOutdated = false
        previewMode = .generated
    }

    // MARK: - LLM Operations (Phase 3)

    func refinePrompt() {
        guard let config = activeModelConfig else { return }
        let sourceText = generatedPrompt.hasEditableDraft
            ? generatedPrompt.editedText
            : generatedPrompt.baseText
        guard !sourceText.isEmpty else { return }

        // Check fingerprint cache
        let fingerprint = computeFingerprint(taskKind: "refine", sourceText: sourceText)
        if let fingerprint, fingerprint == lastRefineFingerprint, refinedPrompt != nil {
            llmTaskState = .completed
            return
        }

        // Cancel any in-flight request
        activeLLMTask?.cancel()

        llmTaskState = .refining

        activeLLMTask = Task { [weak self] in
            guard let self else { return }
            do {
                // Load API key from keychain for providers that require it
                var apiKey: String?
                if config.provider.requiresAPIKey {
                    if let data = try? self.keychainRepository.load(key: config.provider.keychainAccount) {
                        apiKey = String(data: data, encoding: .utf8)
                    }
                    guard apiKey != nil else {
                        self.llmTaskState = .failed(.apiKeyMissing)
                        return
                    }
                }

                let result = try await self.refinePromptUseCase.execute(
                    prompt: sourceText,
                    config: config,
                    apiKey: apiKey
                )

                guard !Task.isCancelled else {
                    self.llmTaskState = .cancelled
                    return
                }

                self.refinedPrompt = result
                self.lastRefineFingerprint = fingerprint
                self.llmTaskState = .completed
            } catch is CancellationError {
                self.llmTaskState = .cancelled
            } catch let error as LLMError {
                self.llmTaskState = .failed(error)
            } catch {
                self.llmTaskState = .failed(.providerUnavailable)
            }
        }
    }

    func translatePrompt() {
        guard let config = activeModelConfig else { return }

        // Priority: edited text > refined prompt > base prompt
        var sourceText = ""
        if generatedPrompt.hasEditableDraft && !generatedPrompt.editedText.isEmpty {
            sourceText = generatedPrompt.editedText
        } else if let refined = refinedPrompt, !refined.isEmpty {
            sourceText = refined
        } else {
            sourceText = generatedPrompt.baseText
        }
        guard !sourceText.isEmpty else { return }

        // Check fingerprint cache
        let fingerprint = computeFingerprint(taskKind: "translate", sourceText: sourceText)
        if let fingerprint, fingerprint == lastTranslateFingerprint, translatedPrompt != nil {
            llmTaskState = .completed
            return
        }

        // Cancel any in-flight request
        activeLLMTask?.cancel()

        llmTaskState = .translating

        activeLLMTask = Task { [weak self] in
            guard let self else { return }
            do {
                var apiKey: String?
                if config.provider.requiresAPIKey {
                    if let data = try? self.keychainRepository.load(key: config.provider.keychainAccount) {
                        apiKey = String(data: data, encoding: .utf8)
                    }
                    guard apiKey != nil else {
                        self.llmTaskState = .failed(.apiKeyMissing)
                        return
                    }
                }

                let result = try await self.translatePromptUseCase.execute(
                    text: sourceText,
                    config: config,
                    apiKey: apiKey
                )

                guard !Task.isCancelled else {
                    self.llmTaskState = .cancelled
                    return
                }

                self.translatedPrompt = result
                self.lastTranslateFingerprint = fingerprint
                self.llmTaskState = .completed
            } catch is CancellationError {
                self.llmTaskState = .cancelled
            } catch let error as LLMError {
                self.llmTaskState = .failed(error)
            } catch {
                self.llmTaskState = .failed(.providerUnavailable)
            }
        }
    }

    func cancelActiveLLMTask() {
        activeLLMTask?.cancel()
        activeLLMTask = nil
    }

    // MARK: - Draft Persistence

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

    // MARK: - Private Helpers

    private func computeFingerprint(taskKind: String, sourceText: String) -> String? {
        guard let config = activeModelConfig else { return nil }
        let keywordIDs = selectedKeywordIDs.sorted()
        let payload: [String: Any] = [
            "taskKind": taskKind,
            "sourceText": sourceText,
            "provider": config.provider.rawValue,
            "modelID": config.modelID,
            "temperature": config.temperature,
            "maxTokens": config.maxTokens,
            "keywordIDs": keywordIDs,
            "subtopicID": selectedSubtopicID ?? ""
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: .sortedKeys) else { return nil }
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
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

        // Stale propagation: mark LLM results as stale when selections change
        if refinedPrompt != nil || translatedPrompt != nil {
            llmTaskState = .stale
        }
    }
}
