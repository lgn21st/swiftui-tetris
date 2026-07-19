import Testing
import Core
@testable import UI

@Suite struct FocusPauseHandlerTests {
    @Test func testHandlerDoesNotPauseOnDeactivate() {
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

        #expect(!state.paused)
        #expect(!overlay.isPaused)

        let originalX = state.active.x
        input.tick(elapsedMs: 100, canAccept: true, state: &state)
        #expect(state.active.x == originalX)
    }
}
