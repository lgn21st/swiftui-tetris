import Testing
import AppKit
@testable import UI

@Suite struct KeyCommandMapperTests {
    @Test func testFullscreenToggleShortcut() {
        #expect(KeyCommandMapper.isFullScreenToggle(key: "f", modifiers: [.command, .control]))
    }

    @Test func testFullscreenToggleShortcutIgnoresMissingModifiers() {
        #expect(!KeyCommandMapper.isFullScreenToggle(key: "f", modifiers: [.command]))
        #expect(!KeyCommandMapper.isFullScreenToggle(key: "f", modifiers: [.control]))
    }

    @Test func testFullscreenToggleShortcutIgnoresOtherKeys() {
        #expect(!KeyCommandMapper.isFullScreenToggle(key: "p", modifiers: [.command, .control]))
    }
}
