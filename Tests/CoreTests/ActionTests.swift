import XCTest
@testable import Core

final class ActionTests: XCTestCase {
    func testApplyActionSoftDropAddsScore() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.score = 0
        state.apply(action: .softDrop)
        XCTAssertEqual(state.score, 1)
    }

    func testApplyActionHardDropLocksAndScores() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.score = 0
        state.apply(action: .hardDrop)
        XCTAssertGreaterThan(state.score, 0)
        XCTAssertEqual(state.dropTimerMs, 0)
    }

    func testApplyActionPauseToggles() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.apply(action: .pause)
        XCTAssertTrue(state.paused)
        state.apply(action: .pause)
        XCTAssertFalse(state.paused)
    }
}
