import SwiftUI

struct PromptDraftEditorView: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Draft")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Describe the change, problem, or goal.")
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(8)
            }
            .frame(height: 180)
            .background(Color(nsColor: .textBackgroundColor).opacity(0.8))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.accentColor.opacity(0.24), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}
