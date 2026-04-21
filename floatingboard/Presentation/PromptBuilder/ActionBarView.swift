import SwiftUI

struct ActionBarView: View {
    let canCopy: Bool
    let canRegenerate: Bool
    let copyFeedbackMessage: String?
    let onCopy: () -> Void
    let onRegenerate: () -> Void

    var body: some View {
        HStack {
            if let copyFeedbackMessage, !copyFeedbackMessage.isEmpty {
                Text(copyFeedbackMessage)
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            Spacer()

            Button("Regenerate") {
                onRegenerate()
            }
            .buttonStyle(.bordered)
            .disabled(!canRegenerate)

            Button("Copy") {
                onCopy()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canCopy)
        }
    }
}
