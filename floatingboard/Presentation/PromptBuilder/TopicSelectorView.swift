import SwiftUI

struct TopicSelectorView: View {
    let topics: [Topic]
    let selectedTopicID: TopicID
    let onSelect: (TopicID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Topic")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(topics, id: \.id) { topic in
                    Button(topic.title) {
                        onSelect(topic.id)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(topic.id == selectedTopicID ? .accentColor : .gray.opacity(0.4))
                }
            }
        }
    }
}
