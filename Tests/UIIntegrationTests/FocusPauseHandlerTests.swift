import Testing
import Core
@testable import UI

@Suite struct FocusPauseHandlerTests {
    @Test func testHandlerDoesNotPauseOnDeactivate() {
        let state = GameState(config: GameConfig())
        let input = InputEngine()
        let handler = FocusPauseHandler()

        #expect(input.setLeftHeld(true) == .moveLeft)
        let overlay = handler.handleAppActiveChanged(
            isActive: false,
            snapshot: state.snapshot(),
            input: input,
            started: true
        )

        #expect(!state.paused)
        #expect(!overlay.isPaused)

        #expect(input.setLeftHeld(true) == .moveLeft)
    }
}
