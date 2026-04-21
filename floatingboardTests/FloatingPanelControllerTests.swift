import AppKit
import SwiftUI
import Testing
@testable import floatingboard

@MainActor
struct FloatingPanelControllerTests {
    @Test
    func showAndClosePanelChangesVisibility() {
        let controller = FloatingPanelController()

        controller.show(rootView: Text("Smoke Test"))

        let visiblePanel = NSApp.windows.first(where: { $0 is FloatingPanel })
        #expect(visiblePanel != nil)
        #expect(visiblePanel?.isVisible == true)

        controller.close()

        #expect(visiblePanel?.isVisible == false)
    }

    @Test
    func floatingPanelDoesNotHideWhenAppDeactivates() {
        let controller = FloatingPanelController()

        controller.show(rootView: Text("Smoke Test"))

        let visiblePanel = NSApp.windows.first(where: { $0 is FloatingPanel }) as? FloatingPanel
        #expect(visiblePanel?.hidesOnDeactivate == false)
        #expect(visiblePanel?.collectionBehavior.contains(.canJoinAllSpaces) == true)
        #expect(visiblePanel?.collectionBehavior.contains(.fullScreenAuxiliary) == true)

        controller.close()
    }
}
