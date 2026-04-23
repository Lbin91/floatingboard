import SwiftUI

struct SelectionPanelView: View {
    let topics: [Topic]
    let selectedTopicID: TopicID
    let subtopics: [Subtopic]
    let selectedSubtopicID: String?
    let visibleKeywordGroups: [KeywordGroup]
    let keywordsForGroup: (String) -> [KeywordOption]
    let isSelected: (String) -> Bool
    let selectedKeywordTitles: [String]
    let onSelectSubtopic: (String) -> Void
    let onToggleKeyword: (String) -> Void

    @State private var selectionStep: SelectionStep = .subtopic
    @State private var hasUserSelectedSubtopic = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            ScrollView(.vertical) {
                Group {
                    switch activeStep {
                    case .subtopic:
                        subtopicSelection
                    case .keywords:
                        keywordSelection
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 2)
            }
            .scrollIndicators(.visible)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.secondary.opacity(0.14), lineWidth: 1)
        )
    }

    private var activeStep: SelectionStep {
        guard hasUserSelectedSubtopic, selectedSubtopicID != nil else {
            return .subtopic
        }

        return selectionStep
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("Selection")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer(minLength: 8)

            if let selectedTopicTitle {
                CompactTopicPillView(title: selectedTopicTitle)
            }
        }
    }

    private var subtopicSelection: some View {
        SubtopicSelectorView(
            subtopics: subtopics,
            selectedSubtopicID: selectedSubtopicID,
            showsTitle: true
        ) { subtopicID in
            onSelectSubtopic(subtopicID)
            hasUserSelectedSubtopic = true
            selectionStep = .keywords
        }
    }

    private var keywordSelection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                selectionStep = .subtopic
            } label: {
                HStack(spacing: 8) {
                    Text(selectedSubtopicTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

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

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(minHeight: 34)
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            KeywordPickerView(
                groups: visibleKeywordGroups,
                keywordsForGroup: keywordsForGroup,
                isSelected: isSelected,
                onToggle: onToggleKeyword
            )
        }
    }

    private var selectedTopicTitle: String? {
        topics.first { $0.id == selectedTopicID }?.title
    }

    private var selectedSubtopicTitle: String {
        subtopics.first { $0.id == selectedSubtopicID }?.title ?? String(localized: "Subtopic")
    }

    private var keywordSelectionSummary: String {
        let count = selectedKeywordTitles.count
        let label = count == 1 ? String(localized: "keyword") : String(localized: "keywords")
        return "\(count) \(label)"
    }

    private enum SelectionStep {
        case subtopic
        case keywords
    }
}
