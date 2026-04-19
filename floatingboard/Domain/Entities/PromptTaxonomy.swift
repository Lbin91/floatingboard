import Foundation

struct PromptTaxonomy: Equatable {
    let schemaVersion: Int
    let sourceLocale: String
    let supportedUILabelLocales: [String]
    let topics: [Topic]
    let sectionDefinitions: [SectionDefinition]
    let keywordGroups: [KeywordGroup]
    let subtopics: [Subtopic]
    let keywords: [KeywordOption]
    let visibilityRules: [VisibilityRule]
    let assemblyRules: AssemblyRules

    func topic(id: TopicID) -> Topic? {
        topics.first { $0.id == id }
    }

    func subtopic(id: String) -> Subtopic? {
        subtopics.first { $0.id == id }
    }

    func keyword(id: String) -> KeywordOption? {
        keywords.first { $0.id == id }
    }

    func visibilityRule(for subtopicID: String) -> VisibilityRule? {
        visibilityRules.first { $0.subtopicID == subtopicID }
    }

    func finalInstructionTemplate(for subtopicID: String) -> String? {
        assemblyRules.subtopicRules.first { $0.subtopicID == subtopicID }?.finalInstructionTemplate
    }
}

struct Topic: Equatable {
    let id: TopicID
    let title: String
    let summary: String
    let defaultSubtopicID: String
    let sortOrder: Int
}

struct SectionDefinition: Equatable {
    let id: String
    let title: String
}

struct KeywordGroup: Equatable {
    let id: String
    let title: String
    let displayOrder: Int
    let maxVisibleKeywords: Int
}

struct Subtopic: Equatable {
    let id: String
    let topicID: TopicID
    let title: String
    let description: String
    let keywordGroupIDs: [String]
    let defaultKeywordIDs: [String]
    let enabledSectionIDs: [String]
}

enum KeywordType: String, Codable, Equatable {
    case context
    case priority
    case constraint
    case output
    case verification
}

struct KeywordOption: Equatable {
    let id: String
    let groupID: String
    let type: KeywordType
    let title: String
    let promptFragment: String
    let isPrimary: Bool
    let supportedSubtopicIDs: [String]
}

struct VisibilityRule: Equatable {
    let subtopicID: String
    let visibleGroupIDs: [String]
    let visibleKeywordIDs: [String]
}

struct AssemblyRules: Equatable {
    let sectionOrder: [String]
    let emptySectionPolicy: String
    let sourceOfTruth: String
    let subtopicRules: [SubtopicAssemblyRule]
}

struct SubtopicAssemblyRule: Equatable {
    let subtopicID: String
    let finalInstructionTemplate: String
}
