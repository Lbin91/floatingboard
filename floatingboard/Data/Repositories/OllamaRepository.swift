import Foundation

final class OllamaRepository: AIRepository {
    func refine(prompt: String, config: LLMModelConfig, apiKey: String?) async throws -> String {
        let systemMessage = LLMChatMessage(
            role: "system",
            content: "You are refining an already-structured prompt. Preserve the user intent and selected constraints. Do not invent new requirements. Keep the output concise but actionable."
        )

        let userMessage = LLMChatMessage(role: "user", content: prompt)

        return try await sendRequest(
            config: config,
            systemMessage: systemMessage,
            userMessage: userMessage
        )
    }

    func translate(text: String, config: LLMModelConfig, apiKey: String?) async throws -> String {
        let systemMessage = LLMChatMessage(
            role: "system",
            content: "Translate faithfully. Preserve structure and constraints. Do not summarize. Keep code, identifiers, and file names intact."
        )

        let userMessage = LLMChatMessage(role: "user", content: text)

        return try await sendRequest(
            config: config,
            systemMessage: systemMessage,
            userMessage: userMessage
        )
    }

    private func sendRequest(
        config: LLMModelConfig,
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

        let endpoint = config.endpoint ?? AIProvider.ollama.defaultEndpoint
        guard let url = URL(string: endpoint) else {
            throw LLMError.connectionFailed("잘못된 endpoint: \(endpoint)")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 120
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.malformedResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 404:
            throw LLMError.connectionFailed("Ollama가 실행 중인지 확인하세요. endpoint: \(endpoint)")
        case 500...599:
            throw LLMError.providerUnavailable
        default:
            throw LLMError.connectionFailed("HTTP \(httpResponse.statusCode)")
        }

        let decoded = try JSONDecoder().decode(OllamaChatResponse.self, from: data)
        guard let content = decoded.message.content, !content.isEmpty else {
            throw LLMError.malformedResponse
        }

        return content
    }
}
