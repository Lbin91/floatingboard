import SwiftUI

struct ActionBarView: View {
    let canCopy: Bool
    let canRegenerate: Bool
    let copyFeedbackMessage: String?
    let llmTaskState: LLMTaskState
    let canRefine: Bool
    let canTranslate: Bool
    let isLLMLoading: Bool
    let onCopy: () -> Void
    let onRegenerate: () -> Void
    let onRefine: () -> Void
    let onTranslate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                if let copyFeedbackMessage, !copyFeedbackMessage.isEmpty {
                    Text(copyFeedbackMessage)
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                Spacer()

                HStack(spacing: 4) {
                    if llmTaskState == .refining {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Button {
                        onRefine()
                    } label: {
                        Label("Refine", systemImage: "sparkles")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canRefine || llmTaskState == .translating || llmTaskState == .refining)
                }

                if llmTaskState == .stale {
                    Text("STALE")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.yellow)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                }

                HStack(spacing: 4) {
                    if llmTaskState == .translating {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Button {
                        onTranslate()
                    } label: {
                        Label("Translate", systemImage: "globe")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!canTranslate || llmTaskState == .translating || llmTaskState == .refining)
                }

                Button {
                    onRegenerate()
                } label: {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .disabled(!canRegenerate)

                Button {
                    onCopy()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canCopy)
            }

            if case .failed(let error) = llmTaskState {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}
