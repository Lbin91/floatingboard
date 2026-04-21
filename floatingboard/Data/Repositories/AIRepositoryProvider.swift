import Foundation

@MainActor
final class AIRepositoryProvider {
    private let openRouter: OpenRouterRepository
    private let ollama: OllamaRepository

    init(openRouter: OpenRouterRepository, ollama: OllamaRepository) {
        self.openRouter = openRouter
        self.ollama = ollama
    }

    func resolve(for provider: AIProvider) -> AIRepository {
        switch provider {
        case .openRouter: openRouter
        case .ollama: ollama
        }
    }
}
