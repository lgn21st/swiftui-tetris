import Testing
@testable import UI
@testable import Core

@Suite struct InputRepeatFlowTests {
    @Test func testLeftRepeatAfterDasArr() {
        var state = GameState(config: GameConfig(), seed: 1)
        let engine = InputEngine()
        #expect(engine.setLeftHeld(true) == .moveLeft)
        #expect(state.active.x == 3)

        engine.produceActions(elapsedMs: 150, canAccept: true) { state.apply(action: $0) }
        #expect(state.active.x == 3)

        engine.produceActions(elapsedMs: 50, canAccept: true) { state.apply(action: $0) }
        #expect(state.active.x == 2)
    }
}
