import XCTest
import AppKit
@testable import UI

final class WindowDefaultsTests: XCTestCase {
    func testWindowDefaultsApplySizeAndRestoration() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        WindowDefaults.apply(to: window)

        let contentSize = window.contentRect(forFrameRect: window.frame).size
        XCTAssertEqual(contentSize.width, WindowConfig.defaultWidth, accuracy: 0.5)
        XCTAssertEqual(contentSize.height, WindowConfig.defaultHeight, accuracy: 0.5)
        XCTAssertEqual(window.contentMinSize.width, WindowConfig.minWidth)
        XCTAssertEqual(window.contentMinSize.height, WindowConfig.minHeight)
        XCTAssertFalse(window.isRestorable)
    }
}
