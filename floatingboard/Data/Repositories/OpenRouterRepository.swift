import Foundation

final class OpenRouterRepository: AIRepository {
    private let endpoint = "https://openrouter.ai/api/v1/chat/completions"

    func refine(prompt: String, config: LLMModelConfig, apiKey: String?) async throws -> String {
        guard let apiKey, !apiKey.isEmpty else {
            throw LLMError.apiKeyMissing
        }

        let systemMessage = LLMChatMessage(
            role: "system",
            content: "You are refining an already-structured prompt. Preserve the user intent and selected constraints. Do not invent new requirements. Keep the output concise but actionable. Respect attached references only as provided."
        )

        let userMessage = LLMChatMessage(role: "user", content: prompt)

        return try await sendRequest(
            config: config,
            apiKey: apiKey,
            systemMessage: systemMessage,
            userMessage: userMessage
        )
    }

    func translate(text: String, config: LLMModelConfig, apiKey: String?) async throws -> String {
        guard let apiKey, !apiKey.isEmpty else {
            throw LLMError.apiKeyMissing
        }

        let systemMessage = LLMChatMessage(
            role: "system",
            content: "Translate faithfully. Preserve structure and constraints. Do not summarize. Keep code, identifiers, and file names intact."
        )

        let userMessage = LLMChatMessage(role: "user", content: text)

        return try await sendRequest(
            config: config,
            apiKey: apiKey,
            systemMessage: systemMessage,
            userMessage: userMessage
        )
    }

    private func sendRequest(
        config: LLMModelConfig,
        apiKey: String,
        systemMessage: LLMChatMessage,
        userMessage: LLMChatMessage
    ) async throws -> String {
        let request = LLMChatRequest(
            model: config.modelID,
            messages: [systemMessage, userMessage],
            stream: false,
            temperature: config.temperature,
            maxTokens: config.maxTokens
        )

        var urlRequest = URLRequest(url: URL(string: endpoint)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 60
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.malformedResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw LLMError.authenticationFailed
        case 429:
            throw LLMError.rateLimited
        case 408:
            throw LLMError.timeout
        case 500...599:
            throw LLMError.providerUnavailable
        default:
            throw LLMError.connectionFailed("HTTP \(httpResponse.statusCode)")
        }

        let decoded = try JSONDecoder().decode(LLMChatResponse.self, from: data)
        guard let content = decoded.firstContent, !content.isEmpty else {
            throw LLMError.malformedResponse
        }

        return content
    }
}
