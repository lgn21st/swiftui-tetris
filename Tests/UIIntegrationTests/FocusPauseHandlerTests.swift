import XCTest
import Core
@testable import UI

final class FocusPauseHandlerTests: XCTestCase {
    func testHandlerDoesNotPauseOnDeactivate() {
        var state = GameState(config: GameConfig())
        let input = InputEngine()
        let handler = FocusPauseHandler()

        input.setLeftHeld(true, state: &state)
        let overlay = handler.handleAppActiveChanged(
            isActive: false,
            state: &state,
            input: input,
            started: true
        )

        XCTAssertFalse(state.paused)
        XCTAssertFalse(overlay.isPaused)

        let originalX = state.active.x
        input.tick(elapsedMs: 100, canAccept: true, state: &state)
        XCTAssertEqual(state.active.x, originalX)
    }
}
