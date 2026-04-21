import SwiftUI

struct PromptBuilderView: View {
    @Bindable var viewModel: PromptBuilderViewModel
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prompt Builder")
                        .font(.title2.weight(.semibold))
                    Text("Coding-first structured prompt builder")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Close") {
                    onClose()
                }
            }

            TopicSelectorView(
                topics: viewModel.topics,
                selectedTopicID: viewModel.selectedTopicID,
                onSelect: viewModel.selectTopic
            )

            SubtopicSelectorView(
                subtopics: viewModel.subtopics,
                selectedSubtopicID: viewModel.selectedSubtopicID,
                onSelect: viewModel.selectSubtopic
            )

            KeywordPickerView(
                groups: viewModel.visibleKeywordGroups,
                keywordsForGroup: viewModel.keywords(for:),
                isSelected: viewModel.isSelected(_:),
                onToggle: viewModel.toggleKeyword(_:)
            )

            PromptDraftEditorView(text: $viewModel.userDraftText)

            PromptPreviewView(
                previewMode: viewModel.previewMode,
                previewText: viewModel.generatedPrompt.baseText,
                editedText: $viewModel.editedPromptText,
                isEditedDirty: viewModel.generatedPrompt.isEditedDirty,
                isEditedOutdated: viewModel.generatedPrompt.isEditedOutdated,
                errorMessage: viewModel.errorMessage,
                onGeneratedSelected: viewModel.switchToGeneratedMode,
                onEditedSelected: viewModel.switchToEditMode
            )

            ActionBarView(
                canCopy: !viewModel.previewText.isEmpty,
                canRegenerate: viewModel.generatedPrompt.hasEditableDraft,
                copyFeedbackMessage: viewModel.copyFeedbackMessage,
                onCopy: viewModel.copyPreview,
                onRegenerate: viewModel.regenerateFromSelections
            )
        }
        .padding(24)
        .frame(minWidth: 560, minHeight: 520)
    }
}
