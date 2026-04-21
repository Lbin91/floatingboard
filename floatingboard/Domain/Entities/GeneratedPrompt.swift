import Foundation

enum PromptPreviewMode: String, CaseIterable {
    case generated
    case edited
    case refined
    case translated
}

struct GeneratedPrompt: Equatable, Codable {
    var baseText: String = ""
    var editedText: String = ""
    var hasEditableDraft: Bool = false
    var isEditedDirty: Bool = false
    var isEditedOutdated: Bool = false

    var displayedGeneratedText: String {
        baseText
    }

    var displayedEditedText: String {
        hasEditableDraft ? editedText : baseText
    }
}
