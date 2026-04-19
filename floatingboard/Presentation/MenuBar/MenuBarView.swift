import SwiftUI

struct MenuBarView: View {
    let container: DependencyContainer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Open Prompt Builder") {
                container.floatingPanelController.show()
            }

            SettingsLink {
                Text("Preferences")
            }

            Divider()

            Button("Quit FloatingBoard") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(8)
        .frame(minWidth: 220)
    }
}
