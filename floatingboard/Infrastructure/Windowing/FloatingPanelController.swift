import AppKit
import SwiftUI

@MainActor
final class FloatingPanelController {
    private var panel: FloatingPanel?

    func show<Content: View>(rootView: Content) {
        if panel == nil {
            panel = makePanel()
        }

        panel?.contentView = NSHostingView(rootView: rootView)
        if panel?.isVisible != true {
            panel?.center()
        }
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        panel?.orderOut(nil)
    }

    func toggle<Content: View>(rootView: Content) {
        if let panel, panel.isVisible {
            close()
        } else {
            show(rootView: rootView)
        }
    }

    private func makePanel() -> FloatingPanel {
        let panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 680),
            styleMask: [.titled, .fullSizeContentView, .closable],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isReleasedWhenClosed = false
        panel.minSize = NSSize(width: 560, height: 560)
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true

        return panel
    }
}
