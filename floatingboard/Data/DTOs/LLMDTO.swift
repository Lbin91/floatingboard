import Foundation

struct LLMChatRequest: Encodable {
    let model: String
    let messages: [LLMChatMessage]
    let stream: Bool
    let temperature: Double
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, messages, stream, temperature
        case maxTokens = "max_tokens"
    }
}

struct LLMChatMessage: Encodable {
    let role: String
    let content: String
}

struct LLMChatResponse: Decodable {
    let choices: [LLMChoice]

    var firstContent: String? {
        choices.first?.message.content
    }
}

struct LLMChoice: Decodable {
    let message: LLMChoiceMessage
}

struct LLMChoiceMessage: Decodable {
    let content: String?
}

struct OllamaChatResponse: Decodable {
    let message: OllamaMessage
}

struct OllamaMessage: Decodable {
    let content: String?
}
