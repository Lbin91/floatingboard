import Foundation

protocol AIRepository {
    func refine(prompt: String, config: LLMModelConfig, apiKey: String?) async throws -> String
    func translate(text: String, config: LLMModelConfig, apiKey: String?) async throws -> String
}
