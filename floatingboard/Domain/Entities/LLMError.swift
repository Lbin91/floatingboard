import Foundation

enum LLMError: Error, Equatable {
    case apiKeyMissing
    case authenticationFailed
    case timeout
    case rateLimited
    case providerUnavailable
    case malformedResponse
    case cancelled
    case connectionFailed(String)
}

extension LLMError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API 키가 설정되지 않았습니다. 설정에서 API 키를 입력해주세요."
        case .authenticationFailed:
            return "인증에 실패했습니다. API 키를 확인해주세요."
        case .timeout:
            return "요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요."
        case .rateLimited:
            return "요청 한도에 도달했습니다. 잠시 후 다시 시도해주세요."
        case .providerUnavailable:
            return "AI 서비스에 연결할 수 없습니다. 네트워크 상태를 확인해주세요."
        case .malformedResponse:
            return "AI 서비스로부터 올바르지 않은 응답을 받았습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .connectionFailed(let message):
            return "연결에 실패했습니다: \(message)"
        }
    }
}
