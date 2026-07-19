import Testing
@testable import Core

@Suite struct DropScoreTests {
    @Test func testSoftDropAwardsOnePerCell() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.score = 0
        _ = state.softDropStep()
        #expect(state.score == 1)
    }

    @Test func testHardDropAwardsTwoPerCell() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.score = 0
        let dropped = state.hardDrop()
        #expect(dropped > 0)
        #expect(state.score == dropped * 2)
    }
}
