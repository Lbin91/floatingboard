import SwiftUI

struct PromptBuilderView: View {
    @Bindable var viewModel: PromptBuilderViewModel
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            editingArea
        }
        .frame(minWidth: 560, idealWidth: 640, minHeight: 620, idealHeight: 720)
        .background(.regularMaterial)
    }

    private var editingArea: some View {
        VStack(alignment: .leading, spacing: 14) {
            PromptDraftEditorView(text: $viewModel.userDraftText)

            SelectionPanelView(
                topics: viewModel.topics,
                selectedTopicID: viewModel.selectedTopicID,
                subtopics: viewModel.subtopics,
                selectedSubtopicID: viewModel.selectedSubtopicID,
                visibleKeywordGroups: viewModel.visibleKeywordGroups,
                keywordsForGroup: viewModel.keywords(for:),
                isSelected: viewModel.isSelected(_:),
                selectedKeywordTitles: selectedKeywordTitles,
                onSelectSubtopic: viewModel.selectSubtopic,
                onToggleKeyword: viewModel.toggleKeyword(_:)
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
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var selectedKeywordTitles: [String] {
        viewModel.visibleKeywordGroups
            .flatMap { viewModel.keywords(for: $0.id) }
            .filter { viewModel.isSelected($0.id) }
            .map(\.title)
    }
}
