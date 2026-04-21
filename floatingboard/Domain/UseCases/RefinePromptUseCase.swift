import Foundation

struct RefinePromptUseCase {
    private let provider: AIRepositoryProvider

    init(provider: AIRepositoryProvider) {
        self.provider = provider
    }

    func execute(prompt: String, config: LLMModelConfig, apiKey: String?) async throws -> String {
        let repository = provider.resolve(for: config.provider)
        return try await repository.refine(prompt: prompt, config: config, apiKey: apiKey)
    }
}
