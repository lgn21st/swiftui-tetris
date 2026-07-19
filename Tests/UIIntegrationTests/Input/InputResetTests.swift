import Testing
@testable import UI
@testable import Core

@Suite struct InputResetTests {
    @Test func testInputResetClearsHeldRepeats() {
        var state = GameState(config: GameConfig(), seed: 1)
        let engine = InputEngine()

        let startX = state.active.x
        #expect(engine.setLeftHeld(true) == .moveLeft)

        engine.reset()
        engine.produceActions(elapsedMs: 200, canAccept: true) { state.apply(action: $0) }

        #expect(state.active.x == startX)
    }
}
