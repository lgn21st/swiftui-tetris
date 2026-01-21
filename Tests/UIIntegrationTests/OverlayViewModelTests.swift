import XCTest
@testable import UI

final class OverlayViewModelTests: XCTestCase {
    func testOverlayStatePriority() {
        let state = OverlayState(isPaused: true, isGameOver: true, isTitle: false, isSettings: true)
        XCTAssertEqual(state.title, "Game Over")
    }
}
