import SwiftUI

struct KeywordPickerView: View {
    let groups: [KeywordGroup]
    let keywordsForGroup: (String) -> [KeywordOption]
    let isSelected: (String) -> Bool
    let onToggle: (String) -> Void

    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(groups, id: \.id) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.title)
                        .font(.headline)

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                        ForEach(keywordsForGroup(group.id), id: \.id) { keyword in
                            Button(isSelected(keyword.id) ? "✓ \(keyword.title)" : keyword.title) {
                                onToggle(keyword.id)
                            }
                            .buttonStyle(.bordered)
                            .tint(isSelected(keyword.id) ? .accentColor : .secondary)
                        }
                    }
                }
            }
        }
    }
}
