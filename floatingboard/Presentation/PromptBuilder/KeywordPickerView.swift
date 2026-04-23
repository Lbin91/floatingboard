import SwiftUI

struct KeywordPickerView: View {
    let groups: [KeywordGroup]
    let keywordsForGroup: (String) -> [KeywordOption]
    let isSelected: (String) -> Bool
    let onToggle: (String) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(displayGroups, id: \.id) { group in
                HStack(alignment: .top, spacing: 12) {
                    Text(group.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 92, alignment: .leading)
                        .padding(.top, 6)

                    WrappingHStack(horizontalSpacing: 8, verticalSpacing: 8) {
                        ForEach(displayKeywords(for: group), id: \.id) { keyword in
                            Button {
                                onToggle(keyword.id)
                            } label: {
                                HStack(spacing: 6) {
                                    if isSelected(keyword.id) {
                                        Image(systemName: "checkmark")
                                            .font(.caption.weight(.bold))
                                    }
                                    Text(keyword.title)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.85)
                                }
                            }
                            .buttonStyle(CompactChipButtonStyle(isSelected: isSelected(keyword.id)))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if shouldShowExpansionToggle {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Label(isExpanded ? "Less" : expansionTitle, systemImage: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
            }
        }
    }

    private var displayGroups: [KeywordGroup] {
        isExpanded ? groups : Array(groups.prefix(2))
    }

    private var shouldShowExpansionToggle: Bool {
        groups.count > 2 || groups.contains { keywordsForGroup($0.id).count > collapsedKeywordLimit(for: $0) }
    }

    private var expansionTitle: String {
        let hiddenGroupCount = max(0, groups.count - 2)
        return hiddenGroupCount > 0 ? "More (\(hiddenGroupCount))" : "More"
    }

    private func displayKeywords(for group: KeywordGroup) -> [KeywordOption] {
        let keywords = keywordsForGroup(group.id)
        guard !isExpanded else { return keywords }

        let initialKeywords = Array(keywords.prefix(collapsedKeywordLimit(for: group)))
        let selectedOverflow = keywords.dropFirst(initialKeywords.count).filter { isSelected($0.id) }
        return initialKeywords + selectedOverflow
    }

    private func collapsedKeywordLimit(for group: KeywordGroup) -> Int {
        max(1, min(4, group.maxVisibleKeywords))
    }
}
