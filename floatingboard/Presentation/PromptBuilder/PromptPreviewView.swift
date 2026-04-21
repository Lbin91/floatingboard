import SwiftUI

struct PromptPreviewView: View {
    let previewMode: PromptPreviewMode
    let previewText: String
    @Binding var editedText: String
    let isEditedDirty: Bool
    let isEditedOutdated: Bool
    let errorMessage: String?
    let refinedPrompt: String?
    let translatedPrompt: String?
    let llmTaskState: LLMTaskState
    let onGeneratedSelected: () -> Void
    let onEditedSelected: () -> Void
    let onRefinedSelected: () -> Void
    let onTranslatedSelected: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Text("Prompt Preview")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Picker("Preview Mode", selection: selectionBinding) {
                    Text("Generated").tag(PromptPreviewMode.generated)
                    Text("Edited").tag(PromptPreviewMode.edited)
                    Text("Refined").tag(PromptPreviewMode.refined).disabled(refinedPrompt == nil)
                    Text("Translated").tag(PromptPreviewMode.translated).disabled(translatedPrompt == nil)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 8) {
                // Current mode badge
                switch previewMode {
                case .generated:
                    Text("BASE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                case .edited:
                    Text("EDITED")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tint)
                case .refined:
                    Text("REFINED")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tint)
                case .translated:
                    Text("TRANSLATED")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tint)
                }

                // Dirty/outdated badges (only for edited mode)
                if previewMode == .edited && isEditedDirty {
                    Text("DIRTY")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
                if previewMode == .edited && isEditedOutdated {
                    Text("STALE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                }

                // LLM stale badge
                if llmTaskState == .stale {
                    Text("STALE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                }
            }

            switch previewMode {
            case .generated:
                ScrollView {
                    Text(previewText.isEmpty ? "Select a subtopic and start choosing keywords to build the prompt." : previewText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(12)
                }
                .frame(minHeight: 220, maxHeight: .infinity)
                .background(Color(nsColor: .textBackgroundColor).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )

            case .edited:
                TextEditor(text: $editedText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 220, maxHeight: .infinity)
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            case .refined:
                ScrollView {
                    Text(refinedPrompt ?? "No refined prompt yet. Click Refine to generate.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(12)
                }
                .frame(minHeight: 220, maxHeight: .infinity)
                .background(Color(nsColor: .textBackgroundColor).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )

            case .translated:
                ScrollView {
                    Text(translatedPrompt ?? "No translation yet. Click Translate to generate.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(12)
                }
                .frame(minHeight: 220, maxHeight: .infinity)
                .background(Color(nsColor: .textBackgroundColor).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            }

            if let errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            // LLM error display
            if case .failed(let error) = llmTaskState {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxHeight: .infinity)
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
                case .refined:
                    onRefinedSelected()
                case .translated:
                    onTranslatedSelected()
                }
            }
        )
    }
}
