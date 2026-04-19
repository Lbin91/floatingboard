import Foundation

@MainActor
final class DependencyContainer {
    let clipboardManager: ClipboardManager
    let globalHotkeyManager: GlobalHotkeyManager
    let floatingPanelController: FloatingPanelController
    let taxonomyRepository: TaxonomyRepository
    let buildPromptUseCase: BuildPromptUseCase

    init() {
        self.clipboardManager = ClipboardManager()
        self.globalHotkeyManager = GlobalHotkeyManager()
        self.taxonomyRepository = LocalTaxonomyRepository()
        self.buildPromptUseCase = BuildPromptUseCase()
        self.floatingPanelController = FloatingPanelController()
    }
}
