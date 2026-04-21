import Foundation

enum TopicID: String, Codable, CaseIterable {
    case coding
}

struct PromptDraft: Equatable, Codable {
    var topicID: TopicID = .coding
    var subtopicID: String?
    var selectedKeywordIDs: [String] = []
    var userInput: String = ""
}
