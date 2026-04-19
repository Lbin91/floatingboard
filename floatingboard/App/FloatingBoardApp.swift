import SwiftUI

@main
struct FloatingBoardApp: App {
    private let container: DependencyContainer

    init() {
        let container = DependencyContainer()
        container.globalHotkeyManager.start {
            container.showPromptBuilder()
        }
        self.container = container
    }

    var body: some Scene {
        MenuBarExtra("FloatingBoard", systemImage: "sparkles") {
            MenuBarView(container: container)
        }

        Settings {
            PreferencesView()
        }
    }
}
