import SwiftUI

struct AISettingsView: View {
    private let keychainRepository: KeychainRepository

    @AppStorage("ai_provider") private var providerRawValue: String = AIProvider.openRouter.rawValue
    @AppStorage("ai_model_id") private var modelID: String = ""
    @AppStorage("ai_endpoint") private var endpoint: String = ""
    @AppStorage("ai_temperature") private var temperature: Double = 0.7
    @AppStorage("ai_max_tokens") private var maxTokens: Int = 1800

    @State private var apiKey: String = ""
    @State private var isTestingConnection = false
    @State private var testResult: String?
    @State private var testSuccess: Bool = false

    private var provider: AIProvider {
        AIProvider(rawValue: providerRawValue) ?? .openRouter
    }

    init(keychainRepository: KeychainRepository) {
        self.keychainRepository = keychainRepository
    }

    var body: some View {
        Form {
            Section(header: Text("AI Provider")) {
                Picker("Provider", selection: $providerRawValue) {
                    ForEach(AIProvider.allCases, id: \.self) { provider in
                        Text(displayName(for: provider)).tag(provider.rawValue)
                    }
                }
                .pickerStyle(.menu)

                if provider.requiresAPIKey {
                    SecureField("API Key", text: $apiKey)
                } else {
                    TextField("Endpoint", text: $endpoint)
                }

                TextField("Model ID", text: $modelID)
                    .onAppear {
                        if modelID.isEmpty {
                            modelID = provider.defaultModel
                        }
                    }
            }

            Section(header: Text("Model Configuration")) {
                HStack {
                    Text("Temperature")
                    Spacer()
                    Text(String(format: "%.1f", temperature))
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }

                Slider(value: $temperature, in: 0.0...1.0, step: 0.1)

                HStack {
                    Text("Max Tokens")
                    Spacer()
                    TextField("1800", value: $maxTokens, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                HStack {
                    Button(action: testConnection) {
                        if isTestingConnection {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("연결 테스트")
                        }
                    }
                    .disabled(isTestingConnection || !canTestConnection)

                    Spacer()

                    if let result = testResult {
                        Text(result)
                            .foregroundStyle(testSuccess ? .green : .red)
                            .font(.caption)
                    }
                }

                HStack {
                    Spacer()
                    Button("저장") {
                        saveSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            loadAPIKey()
            updateDefaultsForProvider()
        }
        .onChange(of: providerRawValue) { _, _ in
            updateDefaultsForProvider()
        }
    }

    private func displayName(for provider: AIProvider) -> String {
        switch provider {
        case .openRouter: "OpenRouter"
        case .ollama: "Ollama"
        }
    }

    private var canTestConnection: Bool {
        if provider.requiresAPIKey {
            return !apiKey.isEmpty && !modelID.isEmpty
        } else {
            return !endpoint.isEmpty && !modelID.isEmpty
        }
    }

    private func loadAPIKey() {
        do {
            if let data = try keychainRepository.load(key: provider.keychainAccount),
               let loadedKey = String(data: data, encoding: .utf8) {
                apiKey = loadedKey
            }
        } catch {
            // 키가 없거나 로드 실패 - 무시하고 빈 상태로 시작
        }
    }

    private func updateDefaultsForProvider() {
        if modelID.isEmpty {
            modelID = provider.defaultModel
        }
        if endpoint.isEmpty && !provider.requiresAPIKey {
            endpoint = provider.defaultEndpoint
        }
        // 키 체인에서 새 provider의 키 로드
        loadAPIKey()
    }

    private func testConnection() {
        guard canTestConnection else { return }

        isTestingConnection = true
        testResult = nil

        let config = LLMModelConfig(
            provider: provider,
            modelID: modelID,
            endpoint: provider.requiresAPIKey ? nil : endpoint,
            temperature: temperature,
            maxTokens: maxTokens
        )

        let apiKeyValue = provider.requiresAPIKey ? apiKey : nil

        Task { @MainActor in
            do {
                let repository: AIRepository
                switch provider {
                case .openRouter:
                    repository = OpenRouterRepository()
                case .ollama:
                    repository = OllamaRepository()
                }

                _ = try await repository.refine(
                    prompt: "Hello",
                    config: config,
                    apiKey: apiKeyValue
                )

                testResult = "연결 성공"
                testSuccess = true
            } catch {
                testResult = "연결 실패: \(error.localizedDescription)"
                testSuccess = false
            }

            isTestingConnection = false
        }
    }

    private func saveSettings() {
        // API Key를 키 체인에 저장
        if provider.requiresAPIKey && !apiKey.isEmpty {
            do {
                if let data = apiKey.data(using: .utf8) {
                    try keychainRepository.save(key: provider.keychainAccount, data: data)
                }
            } catch {
                testResult = "API 키 저장 실패: \(error.localizedDescription)"
                testSuccess = false
                return
            }
        }

        // @AppStorage가 자동으로 나머지 설정을 저장
        testResult = "설정이 저장되었습니다."
        testSuccess = true
    }
}
