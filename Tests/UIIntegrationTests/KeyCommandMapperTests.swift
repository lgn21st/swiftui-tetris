import XCTest
import AppKit
@testable import UI

final class KeyCommandMapperTests: XCTestCase {
    func testFullscreenToggleShortcut() {
        XCTAssertTrue(KeyCommandMapper.isFullScreenToggle(key: "f", modifiers: [.command, .control]))
    }

    func testFullscreenToggleShortcutIgnoresMissingModifiers() {
        XCTAssertFalse(KeyCommandMapper.isFullScreenToggle(key: "f", modifiers: [.command]))
        XCTAssertFalse(KeyCommandMapper.isFullScreenToggle(key: "f", modifiers: [.control]))
    }

    func testFullscreenToggleShortcutIgnoresOtherKeys() {
        XCTAssertFalse(KeyCommandMapper.isFullScreenToggle(key: "p", modifiers: [.command, .control]))
    }
}
