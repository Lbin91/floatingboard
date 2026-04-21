import Foundation

struct LocalPromptDraftRepository: PromptDraftRepository {
    private let defaults: UserDefaults
    private static let selectionsKey = "com.floatingboard.draft.selections"
    private static let editedPromptKey = "com.floatingboard.draft.editedPrompt"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveDraft(_ draft: PromptDraft, editedPrompt: GeneratedPrompt?) throws {
        let encoder = JSONEncoder()
        let selectionsData = try encoder.encode(draft)
        defaults.set(selectionsData, forKey: Self.selectionsKey)

        if let editedPrompt, editedPrompt.hasEditableDraft {
            let editedData = try encoder.encode(editedPrompt)
            defaults.set(editedData, forKey: Self.editedPromptKey)
        } else {
            defaults.removeObject(forKey: Self.editedPromptKey)
        }
    }

    func loadDraft() throws -> (draft: PromptDraft, editedPrompt: GeneratedPrompt?)? {
        guard let selectionsData = defaults.data(forKey: Self.selectionsKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        let draft = try decoder.decode(PromptDraft.self, from: selectionsData)
        let editedPrompt: GeneratedPrompt? = {
            guard let editedData = defaults.data(forKey: Self.editedPromptKey) else { return nil }
            return try? decoder.decode(GeneratedPrompt.self, from: editedData)
        }()

        return (draft: draft, editedPrompt: editedPrompt)
    }

    func clearDraft() throws {
        defaults.removeObject(forKey: Self.selectionsKey)
        defaults.removeObject(forKey: Self.editedPromptKey)
    }
}
