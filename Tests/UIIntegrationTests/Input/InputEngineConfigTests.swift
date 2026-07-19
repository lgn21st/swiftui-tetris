import Testing
@testable import UI
@testable import Core

@Suite struct InputEngineConfigTests {
    @Test func testInputEngineUsesUpdatedRepeatConfig() {
        var state = GameState(config: GameConfig())
        let engine = InputEngine()

        engine.setLeftHeld(true, state: &state)
        let initialX = state.active.x

        engine.tick(elapsedMs: 150, canAccept: true, state: &state)
        #expect(state.active.x == initialX)

        engine.tick(elapsedMs: 50, canAccept: true, state: &state)
        #expect(state.active.x == initialX - 1)

        engine.updateConfig(
            repeatConfig: RepeatConfig(dasMs: 0, arrMs: 10),
            softDropRepeatConfig: RepeatConfig(dasMs: 0, arrMs: 10)
        )

        let updatedX = state.active.x
        engine.tick(elapsedMs: 10, canAccept: true, state: &state)
        #expect(state.active.x == updatedX - 1)
    }

    @Test func testArrZeroDisablesRepeat() {
        var state = GameState(config: GameConfig())
        let engine = InputEngine()
        engine.updateConfig(
            repeatConfig: RepeatConfig(dasMs: 0, arrMs: 0),
            softDropRepeatConfig: RepeatConfig(dasMs: 0, arrMs: 0)
        )
        engine.setLeftHeld(true, state: &state)
        let initialX = state.active.x

        engine.tick(elapsedMs: 100, canAccept: true, state: &state)
        #expect(state.active.x == initialX)
    }
}
