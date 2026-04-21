import Foundation

@MainActor
final class DependencyContainer {
    let clipboardManager: ClipboardManager
    let globalHotkeyManager: GlobalHotkeyManager
    let floatingPanelController: FloatingPanelController
    let taxonomyRepository: TaxonomyRepository
    let buildPromptUseCase: BuildPromptUseCase
    let draftRepository: PromptDraftRepository

    // Phase 3 — LLM dependencies
    let keychainRepository: KeychainRepository
    let aiRepositoryProvider: AIRepositoryProvider
    let refinePromptUseCase: RefinePromptUseCase
    let translatePromptUseCase: TranslatePromptUseCase

    let promptBuilderViewModel: PromptBuilderViewModel

    init() {
        self.clipboardManager = ClipboardManager()
        self.globalHotkeyManager = GlobalHotkeyManager()
        self.taxonomyRepository = LocalTaxonomyRepository()
        self.buildPromptUseCase = BuildPromptUseCase()
        self.draftRepository = LocalPromptDraftRepository()

        // Phase 3 — LLM dependencies
        self.keychainRepository = KeychainRepositoryImpl()

        let openRouter = OpenRouterRepository()
        let ollama = OllamaRepository()
        self.aiRepositoryProvider = AIRepositoryProvider(openRouter: openRouter, ollama: ollama)

        self.refinePromptUseCase = RefinePromptUseCase(provider: aiRepositoryProvider)
        self.translatePromptUseCase = TranslatePromptUseCase(provider: aiRepositoryProvider)

        self.promptBuilderViewModel = PromptBuilderViewModel(
            taxonomyRepository: taxonomyRepository,
            buildPromptUseCase: buildPromptUseCase,
            clipboardManager: clipboardManager,
            draftRepository: draftRepository,
            keychainRepository: keychainRepository,
            refinePromptUseCase: refinePromptUseCase,
            translatePromptUseCase: translatePromptUseCase
        )
        self.floatingPanelController = FloatingPanelController()
    }

    func showPromptBuilder() {
        floatingPanelController.show(
            rootView: PromptBuilderView(
                viewModel: promptBuilderViewModel,
                onClose: { [weak self] in
                    guard let self else { return }
                    self.promptBuilderViewModel.cancelActiveLLMTask()
                    self.promptBuilderViewModel.saveDraft()
                    self.floatingPanelController.close()
                }
            )
        )
    }
}
