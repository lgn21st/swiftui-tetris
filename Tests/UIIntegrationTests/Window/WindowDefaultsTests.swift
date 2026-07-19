import Testing
import AppKit
@testable import UI

@Suite @MainActor struct WindowDefaultsTests {
    @Test func testWindowDefaultsApplySizeAndRestoration() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        WindowDefaults.apply(to: window)

        let contentSize = window.contentRect(forFrameRect: window.frame).size
        #expect(abs((contentSize.width) - (WindowConfig.defaultWidth)) <= (0.5))
        #expect(abs((contentSize.height) - (WindowConfig.defaultHeight)) <= (0.5))
        #expect(window.contentMinSize.width == WindowConfig.minWidth)
        #expect(window.contentMinSize.height == WindowConfig.minHeight)
        #expect(!window.isRestorable)
    }
}
