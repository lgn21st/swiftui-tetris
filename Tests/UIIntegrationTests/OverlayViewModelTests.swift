import XCTest
@testable import UI

final class OverlayViewModelTests: XCTestCase {
    func testOverlayStatePriority() {
        let state = OverlayState(isPaused: true, isGameOver: true, isTitle: false)
        XCTAssertEqual(state.title, "Game Over")
    }

    func testOverlayAccessibilityLabelCombinesTitleAndMessage() {
        let state = OverlayState(isPaused: true, isGameOver: false, isTitle: false)
        XCTAssertEqual(
            OverlayView.accessibilityLabel(for: state),
            "Paused. Press P to resume · R to restart"
        )
    }

    func testOverlayAccessibilityLabelIncludesOnboardingHints() {
        let state = OverlayState(
            isPaused: false,
            isGameOver: false,
            isTitle: true,
            onboardingHints: ["Move: Left/Right", "Rotate: Up"]
        )
        XCTAssertEqual(
            OverlayView.accessibilityLabel(for: state),
            "Title. Press Space or Enter to start. Move: Left/Right Rotate: Up"
        )
    }
}
