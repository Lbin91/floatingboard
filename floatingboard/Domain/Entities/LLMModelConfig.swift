import Foundation

struct LLMModelConfig: Equatable, Codable {
    let provider: AIProvider
    var modelID: String
    var endpoint: String?
    var temperature: Double
    var maxTokens: Int
}
