import Testing
@testable import UI
@testable import Core

@Suite struct InputRepeatFlowTests {
    @Test func testLeftRepeatAfterDasArr() {
        var state = GameState(config: GameConfig(), seed: 1)
        let engine = InputEngine()
        engine.setLeftHeld(true, state: &state)
        #expect(state.active.x == 2)

        engine.tick(elapsedMs: 150, canAccept: true, state: &state)
        #expect(state.active.x == 2)

        engine.tick(elapsedMs: 50, canAccept: true, state: &state)
        #expect(state.active.x == 1)
    }
}
