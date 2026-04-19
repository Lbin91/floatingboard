import SwiftUI

struct PromptPreviewView: View {
    let previewMode: PromptPreviewMode
    let previewText: String
    @Binding var editedText: String
    let isEditedDirty: Bool
    let isEditedOutdated: Bool
    let errorMessage: String?
    let onGeneratedSelected: () -> Void
    let onEditedSelected: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Prompt Preview")
                    .font(.headline)

                Spacer()

                Picker("Preview Mode", selection: selectionBinding) {
                    Text("Generated").tag(PromptPreviewMode.generated)
                    Text("Edited").tag(PromptPreviewMode.edited)
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
            }

            HStack(spacing: 8) {
                Text(previewMode == .generated ? "GENERATED" : "EDITED")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(previewMode == .generated ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))

                if isEditedDirty {
                    Text("DIRTY")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }

                if isEditedOutdated {
                    Text("STALE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                }
            }

            if previewMode == .generated {
                ScrollView {
                    Text(previewText.isEmpty ? "Select a subtopic and start choosing keywords to build the prompt." : previewText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(12)
                }
                .frame(minHeight: 180)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                TextEditor(text: $editedText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 180)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var selectionBinding: Binding<PromptPreviewMode> {
        Binding(
            get: { previewMode },
            set: { newValue in
                switch newValue {
                case .generated:
                    onGeneratedSelected()
                case .edited:
                    onEditedSelected()
                }
            }
        )
    }
}
