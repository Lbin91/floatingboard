import SwiftUI

struct SubtopicSelectorView: View {
    let subtopics: [Subtopic]
    let selectedSubtopicID: String?
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
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
        .scrollIndicators(.hidden)
    }
}
