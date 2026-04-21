import Foundation

enum AIProvider: String, Codable, CaseIterable {
    case openRouter
    case ollama

    var defaultEndpoint: String {
        switch self {
        case .openRouter: "https://openrouter.ai/api/v1/chat/completions"
        case .ollama: "http://localhost:11434/api/chat"
        }
    }

    var defaultModel: String {
        switch self {
        case .openRouter: "openai/gpt-4o-mini"
        case .ollama: "llama3.2"
        }
    }

    var requiresAPIKey: Bool {
        switch self {
        case .openRouter: true
        case .ollama: false
        }
    }

    var keychainAccount: String {
        switch self {
        case .openRouter: "openrouter-api-key"
        case .ollama: "ollama-endpoint"
        }
    }
}
