import SwiftUI

struct TopicSelectorView: View {
    let topics: [Topic]
    let selectedTopicID: TopicID
    let onSelect: (TopicID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Topic")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(topics, id: \.id) { topic in
                    Button {
                        onSelect(topic.id)
                    } label: {
                        Text(topic.title)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SelectionChipButtonStyle(isSelected: topic.id == selectedTopicID))
                }
            }
        }
    }
}

struct CompactTopicPillView: View {
    let title: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.caption.weight(.semibold))
            Text(title)
                .lineLimit(1)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.accentColor.opacity(0.1)))
        .overlay(
            Capsule()
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
        )
        .accessibilityLabel("Topic \(title)")
    }
}

struct SelectionChipButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout.weight(.medium))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct CompactChipButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(nsColor: .controlBackgroundColor).opacity(0.55))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.accentColor.opacity(0.35) : Color.clear, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct WrappingHStack<Content: View>: View {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    @ViewBuilder let content: Content

    init(
        horizontalSpacing: CGFloat = 6,
        verticalSpacing: CGFloat = 6,
        @ViewBuilder content: () -> Content
    ) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content()
    }

    var body: some View {
        FlowLayout(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
            content
        }
    }
}

private struct FlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let rows = rows(for: subviews, in: proposal.width)
        let width = rows.map(\.width).max() ?? 0
        let height = rows.reduce(0) { partial, row in
            partial + row.height
        } + CGFloat(max(0, rows.count - 1)) * verticalSpacing

        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let rows = rows(for: subviews, in: bounds.width)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for item in row.items {
                item.subview.place(
                    at: CGPoint(x: x, y: y + (row.height - item.size.height) / 2),
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + horizontalSpacing
            }

            y += row.height + verticalSpacing
        }
    }

    private func rows(for subviews: Subviews, in proposedWidth: CGFloat?) -> [FlowRow] {
        let maxWidth = proposedWidth ?? .infinity
        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let spacing = currentItems.isEmpty ? 0 : horizontalSpacing
            let wouldOverflow = currentWidth + spacing + size.width > maxWidth

            if wouldOverflow && !currentItems.isEmpty {
                rows.append(FlowRow(items: currentItems, width: currentWidth, height: currentHeight))
                currentItems = []
                currentWidth = 0
                currentHeight = 0
            }

            let nextSpacing = currentItems.isEmpty ? 0 : horizontalSpacing
            currentItems.append(FlowItem(subview: subview, size: size))
            currentWidth += nextSpacing + size.width
            currentHeight = max(currentHeight, size.height)
        }

        if !currentItems.isEmpty {
            rows.append(FlowRow(items: currentItems, width: currentWidth, height: currentHeight))
        }

        return rows
    }

    private struct FlowItem {
        let subview: LayoutSubview
        let size: CGSize
    }

    private struct FlowRow {
        let items: [FlowItem]
        let width: CGFloat
        let height: CGFloat
    }
}
