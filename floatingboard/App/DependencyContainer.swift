import Foundation

@MainActor
final class DependencyContainer {
    let clipboardManager: ClipboardManager
    let globalHotkeyManager: GlobalHotkeyManager
    let floatingPanelController: FloatingPanelController
    let taxonomyRepository: TaxonomyRepository
    let buildPromptUseCase: BuildPromptUseCase
    let promptBuilderViewModel: PromptBuilderViewModel

    init() {
        self.clipboardManager = ClipboardManager()
        self.globalHotkeyManager = GlobalHotkeyManager()
        self.taxonomyRepository = LocalTaxonomyRepository()
        self.buildPromptUseCase = BuildPromptUseCase()
        self.promptBuilderViewModel = PromptBuilderViewModel(
            taxonomyRepository: taxonomyRepository,
            buildPromptUseCase: buildPromptUseCase,
            clipboardManager: clipboardManager
        )
        self.floatingPanelController = FloatingPanelController()
    }

    func showPromptBuilder() {
        floatingPanelController.show(
            rootView: PromptBuilderView(
                viewModel: promptBuilderViewModel,
                onClose: { [weak self] in
                    self?.floatingPanelController.close()
                }
            )
        )
    }
}
