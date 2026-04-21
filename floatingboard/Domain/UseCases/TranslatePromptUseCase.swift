import Foundation

struct TranslatePromptUseCase {
    private let provider: AIRepositoryProvider

    init(provider: AIRepositoryProvider) {
        self.provider = provider
    }

    func execute(
        text: String,
        config: LLMModelConfig,
        apiKey: String?
    ) async throws -> String {
        let repository = provider.resolve(for: config.provider)
        return try await repository.translate(text: text, config: config, apiKey: apiKey)
    }
}
