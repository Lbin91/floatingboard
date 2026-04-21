import SwiftUI

struct PromptBuilderView: View {
    @Bindable var viewModel: PromptBuilderViewModel
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            compactSelectionBar

            Divider()

            editingArea
        }
        .frame(minWidth: 560, idealWidth: 640, minHeight: 560, idealHeight: 680)
        .background(.regularMaterial)
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Prompt Builder")
                    .font(.title3.weight(.semibold))
                Text(selectedSubtopicTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .help("Close")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var compactSelectionBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                CompactTopicPillView(title: selectedTopicTitle)

                Divider()
                    .frame(height: 20)

                SubtopicSelectorView(
                    subtopics: viewModel.subtopics,
                    selectedSubtopicID: viewModel.selectedSubtopicID,
                    onSelect: viewModel.selectSubtopic
                )
            }

            KeywordPickerView(
                groups: viewModel.visibleKeywordGroups,
                keywordsForGroup: viewModel.keywords(for:),
                isSelected: viewModel.isSelected(_:),
                onToggle: viewModel.toggleKeyword(_:)
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
    }

    private var editingArea: some View {
        VStack(alignment: .leading, spacing: 14) {
            PromptDraftEditorView(text: $viewModel.userDraftText)

            PromptPreviewView(
                previewMode: viewModel.previewMode,
                previewText: viewModel.generatedPrompt.baseText,
                editedText: $viewModel.editedPromptText,
                isEditedDirty: viewModel.generatedPrompt.isEditedDirty,
                isEditedOutdated: viewModel.generatedPrompt.isEditedOutdated,
                errorMessage: viewModel.errorMessage,
                refinedPrompt: viewModel.refinedPrompt,
                translatedPrompt: viewModel.translatedPrompt,
                llmTaskState: viewModel.llmTaskState,
                onGeneratedSelected: viewModel.switchToGeneratedMode,
                onEditedSelected: viewModel.switchToEditMode,
                onRefinedSelected: viewModel.switchToRefinedMode,
                onTranslatedSelected: viewModel.switchToTranslatedMode
            )

            ActionBarView(
                canCopy: !viewModel.previewText.isEmpty,
                canRegenerate: viewModel.generatedPrompt.hasEditableDraft,
                copyFeedbackMessage: viewModel.copyFeedbackMessage,
                llmTaskState: viewModel.llmTaskState,
                canRefine: viewModel.activeModelConfig != nil && !viewModel.generatedPrompt.baseText.isEmpty,
                canTranslate: viewModel.activeModelConfig != nil && !viewModel.previewText.isEmpty,
                isLLMLoading: viewModel.llmTaskState == .refining || viewModel.llmTaskState == .translating,
                onCopy: viewModel.copyPreview,
                onRegenerate: viewModel.regenerateFromSelections,
                onRefine: viewModel.refinePrompt,
                onTranslate: viewModel.translatePrompt
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var selectedTopicTitle: String {
        viewModel.topics.first { $0.id == viewModel.selectedTopicID }?.title ?? "Coding"
    }

    private var selectedSubtopicTitle: String {
        viewModel.subtopics.first { $0.id == viewModel.selectedSubtopicID }?.title ?? "Coding-first structured prompt builder"
    }
}
