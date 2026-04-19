import SwiftUI

@main
struct FloatingBoardApp: App {
    @State private var container = DependencyContainer()

    var body: some Scene {
        MenuBarExtra("FloatingBoard", systemImage: "sparkles") {
            MenuBarView(container: container)
        }

        Settings {
            PreferencesView()
        }
    }
}
