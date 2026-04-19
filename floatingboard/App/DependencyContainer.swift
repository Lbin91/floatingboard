import Foundation

@MainActor
final class DependencyContainer {
    let clipboardManager: ClipboardManager
    let globalHotkeyManager: GlobalHotkeyManager
    let floatingPanelController: FloatingPanelController

    init() {
        self.clipboardManager = ClipboardManager()
        self.globalHotkeyManager = GlobalHotkeyManager()
        self.floatingPanelController = FloatingPanelController()
    }
}
