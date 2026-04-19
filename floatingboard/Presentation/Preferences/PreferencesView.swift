import SwiftUI

struct PreferencesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(.title2.weight(.semibold))

            Text("Phase 1 focuses on the local prompt builder flow. Preferences will expand in later steps.")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 220)
    }
}
