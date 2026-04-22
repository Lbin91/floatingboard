import SwiftUI

struct PromptBuilderView: View {
    @Bindable var viewModel: PromptBuilderViewModel
    let onClose: () -> Void
    @State private var isSelectionExpanded = true

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

            selectionDisclosure

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

    private var selectionDisclosure: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isSelectionExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isSelectionExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text("Selection")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Spacer(minLength: 8)

                    selectionSummary
                        .frame(maxWidth: 360, alignment: .trailing)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isSelectionExpanded {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 18) {
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
                    }
                    .padding(.vertical, 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 260)
                .scrollIndicators(.visible)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.secondary.opacity(0.14), lineWidth: 1)
        )
    }

    private var selectionSummary: some View {
        HStack(spacing: 6) {
            Text(selectedSubtopicTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)
                .lineLimit(1)

            Text("·")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Text(keywordSelectionSummary)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if !selectedKeywordTitles.isEmpty {
                Text(selectedKeywordTitles.prefix(2).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
    }

    private var selectedTopicTitle: String {
        viewModel.topics.first { $0.id == viewModel.selectedTopicID }?.title ?? "Coding"
    }

    private var selectedSubtopicTitle: String {
        viewModel.subtopics.first { $0.id == viewModel.selectedSubtopicID }?.title ?? "Coding-first structured prompt builder"
    }

    private var selectedKeywordTitles: [String] {
        viewModel.visibleKeywordGroups
            .flatMap { viewModel.keywords(for: $0.id) }
            .filter { viewModel.isSelected($0.id) }
            .map(\.title)
    }

    private var keywordSelectionSummary: String {
        let count = selectedKeywordTitles.count
        return count == 1 ? "1 keyword" : "\(count) keywords"
    }
}
