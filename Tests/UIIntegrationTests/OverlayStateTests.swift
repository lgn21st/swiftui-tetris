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
}
