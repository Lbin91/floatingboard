import Foundation

protocol PromptDraftRepository {
    func saveDraft(_ draft: PromptDraft, editedPrompt: GeneratedPrompt?) throws
    func loadDraft() throws -> (draft: PromptDraft, editedPrompt: GeneratedPrompt?)?
    func clearDraft() throws
}
