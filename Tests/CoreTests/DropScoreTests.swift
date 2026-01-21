import XCTest
@testable import Core

final class DropScoreTests: XCTestCase {
    func testSoftDropAwardsOnePerCell() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.score = 0
        _ = state.softDropStep()
        XCTAssertEqual(state.score, 1)
    }

    func testHardDropAwardsTwoPerCell() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.score = 0
        let dropped = state.hardDrop()
        XCTAssertGreaterThan(dropped, 0)
        XCTAssertEqual(state.score, dropped * 2)
    }
}
