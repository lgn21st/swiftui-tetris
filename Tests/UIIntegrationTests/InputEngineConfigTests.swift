import XCTest
@testable import UI
@testable import Core

final class InputEngineConfigTests: XCTestCase {
    func testInputEngineUsesUpdatedRepeatConfig() {
        var state = GameState(config: GameConfig())
        let engine = InputEngine()

        engine.setLeftHeld(true, state: &state)
        let initialX = state.active.x

        engine.tick(elapsedMs: 150, canAccept: true, state: &state)
        XCTAssertEqual(state.active.x, initialX)

        engine.tick(elapsedMs: 50, canAccept: true, state: &state)
        XCTAssertEqual(state.active.x, initialX - 1)

        engine.updateConfig(
            repeatConfig: RepeatConfig(dasMs: 0, arrMs: 10),
            softDropRepeatConfig: RepeatConfig(dasMs: 0, arrMs: 10)
        )

        let updatedX = state.active.x
        engine.tick(elapsedMs: 10, canAccept: true, state: &state)
        XCTAssertEqual(state.active.x, updatedX - 1)
    }
}
