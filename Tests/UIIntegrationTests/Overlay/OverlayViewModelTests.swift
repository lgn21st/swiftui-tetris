import Testing
@testable import UI

@Suite struct OverlayViewModelTests {
    @Test func testOverlayStatePriority() {
        let state = OverlayState(isPaused: true, isGameOver: true, isTitle: false)
        #expect(state.title == "Game Over")
    }

    @Test func testOverlayAccessibilityLabelCombinesTitleAndMessage() {
        let state = OverlayState(isPaused: true, isGameOver: false, isTitle: false)
        #expect(OverlayView.accessibilityLabel(for: state) == "Paused. Press P to resume · R to restart")
    }

    @Test func testOverlayAccessibilityLabelIncludesOnboardingHints() {
        let state = OverlayState(
            isPaused: false,
            isGameOver: false,
            isTitle: true,
            onboardingHints: ["Move: Left/Right", "Rotate: Up"]
        )
        #expect(OverlayView.accessibilityLabel(for: state) == "SwiftUI Tetris. Press Space or Enter to start. Move: Left/Right Rotate: Up")
    }
}
