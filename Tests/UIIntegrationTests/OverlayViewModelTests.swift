import XCTest
@testable import UI

final class OverlayViewModelTests: XCTestCase {
    func testOverlayStatePriority() {
        let state = OverlayState(isPaused: true, isGameOver: true, isTitle: false, isSettings: true)
        XCTAssertEqual(state.title, "Game Over")
    }

    func testOverlayViewHidesContentDuringSettings() {
        let state = OverlayState(isPaused: false, isGameOver: false, isTitle: false, isSettings: true)
        XCTAssertFalse(OverlayView.showsContent(for: state))
    }

    func testOverlayAccessibilityLabelCombinesTitleAndMessage() {
        let state = OverlayState(isPaused: true, isGameOver: false, isTitle: false, isSettings: false)
        XCTAssertEqual(
            OverlayView.accessibilityLabel(for: state),
            "Paused. Press P to resume, R to restart"
        )
    }

    func testOverlayAccessibilityLabelEmptyWhenSettingsOpen() {
        let state = OverlayState(isPaused: false, isGameOver: false, isTitle: false, isSettings: true)
        XCTAssertEqual(OverlayView.accessibilityLabel(for: state), "")
    }
}
