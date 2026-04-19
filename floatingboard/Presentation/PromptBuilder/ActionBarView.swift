import SwiftUI

struct ActionBarView: View {
    let canCopy: Bool
    let copyFeedbackMessage: String?
    let onCopy: () -> Void

    var body: some View {
        HStack {
            if let copyFeedbackMessage, !copyFeedbackMessage.isEmpty {
                Text(copyFeedbackMessage)
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            Spacer()

            Button("Copy") {
                onCopy()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canCopy)
        }
    }
}
