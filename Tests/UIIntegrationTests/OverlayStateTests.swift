import XCTest
@testable import UI

final class OverlayStateTests: XCTestCase {
    func testOverlayShowsPaused() {
        let overlay = OverlayState(isPaused: true, isGameOver: false, isTitle: false, isSettings: false)
        XCTAssertEqual(overlay.title, "Paused")
    }

    func testOverlayShowsGameOver() {
        let overlay = OverlayState(isPaused: false, isGameOver: true, isTitle: false, isSettings: false)
        XCTAssertEqual(overlay.title, "Game Over")
    }

    func testOverlayShowsSettings() {
        let overlay = OverlayState(isPaused: false, isGameOver: false, isTitle: false, isSettings: true)
        XCTAssertEqual(overlay.title, "Settings")
    }

    func testOverlayShowsStartHintOnTitle() {
        let overlay = OverlayState(isPaused: false, isGameOver: false, isTitle: true, isSettings: false)
        XCTAssertEqual(overlay.message, "Press Space or Enter to start")
    }
}
