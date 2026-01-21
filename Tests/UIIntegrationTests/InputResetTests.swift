import XCTest
@testable import UI
@testable import Core

final class InputResetTests: XCTestCase {
    func testInputResetClearsHeldRepeats() {
        var state = GameState(config: GameConfig(), seed: 1)
        let engine = InputEngine()

        let startX = state.active.x
        engine.setLeftHeld(true, state: &state)
        XCTAssertEqual(state.active.x, startX - 1)

        engine.reset()
        engine.tick(elapsedMs: 200, canAccept: true, state: &state)

        XCTAssertEqual(state.active.x, startX - 1)
    }
}
