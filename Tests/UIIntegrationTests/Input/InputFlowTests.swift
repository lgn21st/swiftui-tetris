import Testing
@testable import UI
@testable import Core

@Suite struct InputFlowTests {
    @Test func testInputEngineAppliesActions() {
        var state = GameState(config: GameConfig(), seed: 1)
        let engine = InputEngine()
        engine.apply(action: .moveRight, to: &state)
        #expect(state.active.x == 4)
    }
}
