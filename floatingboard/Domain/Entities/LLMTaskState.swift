import Foundation

enum LLMTaskState: Equatable {
    case idle
    case refining
    case translating
    case completed
    case failed(LLMError)
    case cancelled
    case stale
}
