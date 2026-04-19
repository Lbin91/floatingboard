import SwiftUI

struct SubtopicSelectorView: View {
    let subtopics: [Subtopic]
    let selectedSubtopicID: String?
    let onSelect: (String) -> Void

    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subtopic")
                .font(.headline)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(subtopics, id: \.id) { subtopic in
                    Button(subtopic.title) {
                        onSelect(subtopic.id)
                    }
                    .buttonStyle(.bordered)
                    .tint(subtopic.id == selectedSubtopicID ? .accentColor : .secondary)
                }
            }
        }
    }
}
