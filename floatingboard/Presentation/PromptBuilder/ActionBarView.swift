import SwiftUI

struct ActionBarView: View {
    let canCopy: Bool
    let onCopy: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Button("Copy") {
                onCopy()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canCopy)
        }
    }
}
