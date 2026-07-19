import Testing
import AppKit
@testable import UI

@Suite @MainActor struct KeyCaptureViewTests {
    @Test func testKeyCaptureReacquiresFirstResponderOnWindowKey() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        let host = NSView()
        window.contentView = host

        let view = KeyCaptureNSView()
        host.addSubview(view)
        view.viewDidMoveToWindow()

        window.makeFirstResponder(nil)
        NotificationCenter.default.post(name: NSWindow.didBecomeKeyNotification, object: window)

        #expect(window.firstResponder === view)
    }
}
