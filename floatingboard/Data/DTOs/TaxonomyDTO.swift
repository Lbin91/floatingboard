import Foundation

struct TaxonomyDTO: Decodable {
    let schemaVersion: Int
    let sourceLocale: String
    let supportedUILabelLocales: [String]
    let topics: [TopicDTO]
    let sectionDefinitions: [SectionDefinitionDTO]
    let keywordGroups: [KeywordGroupDTO]
    let subtopics: [SubtopicDTO]
    let keywords: [KeywordDTO]
    let visibilityRules: [VisibilityRuleDTO]
    let assemblyRules: AssemblyRulesDTO
}

struct TopicDTO: Decodable {
    let id: String
    let title: String
    let summary: String
    let defaultSubtopicID: String
    let sortOrder: Int
}

struct SectionDefinitionDTO: Decodable {
    let id: String
    let title: String
}

struct KeywordGroupDTO: Decodable {
    let id: String
    let title: String
    let displayOrder: Int
    let maxVisibleKeywords: Int
}

struct SubtopicDTO: Decodable {
    let id: String
    let topicID: String
    let title: String
    let description: String
    let keywordGroupIDs: [String]
    let defaultKeywordIDs: [String]
    let enabledSectionIDs: [String]
}

struct KeywordDTO: Decodable {
    let id: String
    let groupID: String
    let type: KeywordType
    let title: String
    let promptFragment: String
    let isPrimary: Bool
    let supportedSubtopicIDs: [String]
}

struct VisibilityRuleDTO: Decodable {
    let subtopicID: String
    let visibleGroupIDs: [String]
    let visibleKeywordIDs: [String]
}

struct AssemblyRulesDTO: Decodable {
    let sectionOrder: [String]
    let emptySectionPolicy: String
    let sourceOfTruth: String
    let subtopicRules: [SubtopicAssemblyRuleDTO]
}

struct SubtopicAssemblyRuleDTO: Decodable {
    let subtopicID: String
    let finalInstructionTemplate: String
}

extension TaxonomyDTO {
    func toDomain() throws -> PromptTaxonomy {
        PromptTaxonomy(
            schemaVersion: schemaVersion,
            sourceLocale: sourceLocale,
            supportedUILabelLocales: supportedUILabelLocales,
            topics: try topics.map { try $0.toDomain() },
            sectionDefinitions: sectionDefinitions.map { $0.toDomain() },
            keywordGroups: keywordGroups.map { $0.toDomain() },
            subtopics: try subtopics.map { try $0.toDomain() },
            keywords: keywords.map { $0.toDomain() },
            visibilityRules: visibilityRules.map { $0.toDomain() },
            assemblyRules: assemblyRules.toDomain()
        )
    }
}

private extension TopicDTO {
    func toDomain() throws -> Topic {
        guard let topicID = TopicID(rawValue: id) else {
            throw LocalTaxonomyRepositoryError.invalidTopicID(id)
        }

        return Topic(
            id: topicID,
            title: title,
            summary: summary,
            defaultSubtopicID: defaultSubtopicID,
            sortOrder: sortOrder
        )
    }
}

private extension SectionDefinitionDTO {
    func toDomain() -> SectionDefinition {
        SectionDefinition(id: id, title: title)
    }
}

private extension KeywordGroupDTO {
    func toDomain() -> KeywordGroup {
        KeywordGroup(
            id: id,
            title: title,
            displayOrder: displayOrder,
            maxVisibleKeywords: maxVisibleKeywords
        )
    }
}

private extension SubtopicDTO {
    func toDomain() throws -> Subtopic {
        guard let topicID = TopicID(rawValue: topicID) else {
            throw LocalTaxonomyRepositoryError.invalidTopicID(topicID)
        }

        return Subtopic(
            id: id,
            topicID: topicID,
            title: title,
            description: description,
            keywordGroupIDs: keywordGroupIDs,
            defaultKeywordIDs: defaultKeywordIDs,
            enabledSectionIDs: enabledSectionIDs
        )
    }
}

private extension KeywordDTO {
    func toDomain() -> KeywordOption {
        KeywordOption(
            id: id,
            groupID: groupID,
            type: type,
            title: title,
            promptFragment: promptFragment,
            isPrimary: isPrimary,
            supportedSubtopicIDs: supportedSubtopicIDs
        )
    }
}

private extension VisibilityRuleDTO {
    func toDomain() -> VisibilityRule {
        VisibilityRule(
            subtopicID: subtopicID,
            visibleGroupIDs: visibleGroupIDs,
            visibleKeywordIDs: visibleKeywordIDs
        )
    }
}

private extension AssemblyRulesDTO {
    func toDomain() -> AssemblyRules {
        AssemblyRules(
            sectionOrder: sectionOrder,
            emptySectionPolicy: emptySectionPolicy,
            sourceOfTruth: sourceOfTruth,
            subtopicRules: subtopicRules.map { $0.toDomain() }
        )
    }
}

private extension SubtopicAssemblyRuleDTO {
    func toDomain() -> SubtopicAssemblyRule {
        SubtopicAssemblyRule(
            subtopicID: subtopicID,
            finalInstructionTemplate: finalInstructionTemplate
        )
    }
}
