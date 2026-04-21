# FloatingBoard

> macOS menu-bar utility that builds structured prompts for coding tasks. A global hotkey summons a floating panel where you select: **Topic → Subtopic → Keywords → Draft**. The app assembles these into a fixed-skeleton prompt, optionally refines/translates it via LLM, and copies the result to clipboard.

## Features

### Structured Prompt Builder

Instead of staring at a blank text field, you decompose your coding task step by step:

1. **Topic** — Currently "Coding" (extensible architecture)
2. **Subtopic** — Single-select from 8 categories (Implementation, Refactoring, Bug Fix, Testing, Feature Add/Remove, Initial Planning, Planning Revision)
3. **Keywords** — Click-to-toggle chips grouped by role (context, priority, constraint, output, verification). Each subtopic exposes only its relevant 8–12 keywords to avoid selection fatigue.
4. **Draft** — Free-form short text for your specific request

The app instantly assembles a deterministic, section-structured prompt from your selections. No LLM required — the core value works fully offline.

### Prompt Editing (Phase 2)

- **Generated / Edited mode** — Switch between the auto-assembled result and your manual edits
- **Dirty & Outdated badges** — See at a glance whether your edits diverge from the current selections
- **Regenerate** — Discard edits and rebuild from current selections
- **Conflict-safe** — Changing selections never silently overwrites your edits; only the base prompt updates

### State Restoration (Phase 2)

- **Auto-restore on launch** — Topic, subtopic, keywords, draft text, and edited prompt all survive app restart (UserDefaults-backed)
- **Clean separation** — Transient UI state (copy feedback, panel visibility, errors) is not persisted

### Infrastructure

- **Global hotkey** — Carbon `RegisterEventHotKey` for instant panel summon
- **Floating panel** — `NSPanel` subclass, appears above all windows
- **Clipboard copy** — One-click copy with visual feedback
- **Taxonomy-driven** — `coding.json` (893-line declarative contract) drives both UI exposure and prompt assembly
- **Dependency injection** — Manual `DependencyContainer` with protocol-based repositories

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Platform | macOS 14.0+ (Sonoma) |
| Language | Swift 5.9+ (`async/await`, `@Observable`) |
| UI | SwiftUI (builder/settings) + AppKit (`NSPanel`, `NSStatusItem`) |
| Networking | `URLSession` + async/await (non-streaming JSON POST) |
| Secrets | Keychain Services via `Security` framework |
| Persistence | `@AppStorage`, `FileManager`, bundled JSON |
| Hotkey | Carbon `RegisterEventHotKey` |
| LLM providers | OpenRouter / Ollama (user-configured, optional) |

## Architecture

Feature-first layered structure. Dependencies point inward: Data → Domain ← Presentation.

```
FloatingBoard/
├── App/               # Entry point, AppDelegate, DI container
├── Domain/             # Entities, UseCase protocols, Repository protocols
├── Data/               # Repository implementations, DTOs, network layer
├── Presentation/       # SwiftUI Views + @Observable ViewModels
│   ├── PromptBuilder/  # Main builder flow
│   ├── Preferences/    # Settings tabs
│   └── MenuBar/        # Status item menu
├── Infrastructure/     # Hotkey, clipboard, panel controller
└── Resources/          # Assets, PromptTaxonomy/coding.json
```

**Data flow**: User selection → `PromptBuilderViewModel` → `BuildPromptUseCase` → `PromptComposition` → optional LLM refine/translate → preview → `ClipboardManager`.

## Getting Started

```bash
# Clone
git clone git@github.com:Lbin91/floatingboard.git
cd floatingboard

# Build
xcodebuild -scheme floatingboard -destination 'platform=macOS' build

# Run tests
xcodebuild test -scheme floatingboard -destination 'platform=macOS'
```

Requires Xcode 15+ with macOS 14.0+ SDK.

## Documentation

| Document | Description |
|----------|-------------|
| [`docs/spec.md`](docs/spec.md) | Full product spec, data models, UI flow, milestones |
| [`docs/design-system.md`](docs/design-system.md) | Color tokens, typography, spacing, component specs |
| [`docs/llm-integration.md`](docs/llm-integration.md) | LLM session model, request lifecycle, caching |
| [`docs/prompt-examples.md`](docs/prompt-examples.md) | 3 reference prompt outputs |
| [`TODO.md`](TODO.md) | Phase-by-phase implementation checklist |

## Roadmap

| Phase | Status | Scope |
|-------|--------|-------|
| Phase 1 | ✅ Complete | Structured builder UI, prompt assembly, clipboard copy |
| Phase 2 | ✅ Complete | Editable draft, preview/edit mode, state restoration |
| Phase 3 | 🔜 Planned | LLM refine, English translation, reference documents |
| Phase 4 | 📋 Backlog | Reference documents, security-scoped bookmarks |
| Phase 5 | 📋 Backlog | Stabilization, keyboard UX, taxonomy extensibility |

## License

Private project. All rights reserved.
