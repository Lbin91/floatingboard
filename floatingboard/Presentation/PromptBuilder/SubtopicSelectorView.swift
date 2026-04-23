import SwiftUI

struct SubtopicSelectorView: View {
    let subtopics: [Subtopic]
    let selectedSubtopicID: String?
    var showsTitle = true
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsTitle {
                Text("Subtopic")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            WrappingHStack(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(subtopics, id: \.id) { subtopic in
                    Button {
                        onSelect(subtopic.id)
                    } label: {
                        Text(subtopic.title)
                    }
                    .buttonStyle(CompactChipButtonStyle(isSelected: subtopic.id == selectedSubtopicID))
                }
            }
        }
    }
}
