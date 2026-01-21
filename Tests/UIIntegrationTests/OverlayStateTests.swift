import XCTest
@testable import UI

final class OverlayStateTests: XCTestCase {
    func testOverlayShowsPaused() {
        let overlay = OverlayState(isPaused: true, isGameOver: false, isTitle: false)
        XCTAssertEqual(overlay.title, "Paused")
    }

    func testOverlayShowsGameOver() {
        let overlay = OverlayState(isPaused: false, isGameOver: true, isTitle: false)
        XCTAssertEqual(overlay.title, "Game Over")
    }

    func testOverlayShowsStartHintOnTitle() {
        let overlay = OverlayState(isPaused: false, isGameOver: false, isTitle: true)
        XCTAssertEqual(overlay.message, "Press Space or Enter to start")
    }

    func testOverlayShowsPausedHint() {
        let overlay = OverlayState(isPaused: true, isGameOver: false, isTitle: false)
        XCTAssertEqual(overlay.message, "Press P to resume · R to restart")
    }

    func testOverlayShowsGameOverHint() {
        let overlay = OverlayState(isPaused: false, isGameOver: true, isTitle: false)
        XCTAssertEqual(overlay.message, "Press R to restart")
    }

    func testOverlayBlinksStartHintOnTitle() {
        let overlay = OverlayState(isPaused: false, isGameOver: false, isTitle: true)
        XCTAssertTrue(overlay.shouldBlinkStartHint)
        let paused = OverlayState(isPaused: true, isGameOver: false, isTitle: false)
        XCTAssertFalse(paused.shouldBlinkStartHint)
    }
}
