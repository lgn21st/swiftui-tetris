import Testing
@testable import Core

@Suite struct ScoringTests {
    @Test func testClassicSingleLineScoreAtLevelZero() {
        var state = GameState(config: GameConfig())
        state.applyLineClear(cleared: 1, clearedRows: [])
        #expect(state.score == 40)
        #expect(state.lines == 1)
        #expect(state.level == 0)
    }

    @Test func testClassicTetrisScoreAtLevelTwo() {
        var state = GameState(config: GameConfig())
        state.level = 2
        state.applyLineClear(cleared: 4, clearedRows: [])
        #expect(state.score == 1200 * 3)
    }

    @Test func testLevelAdvancesEveryTenLines() {
        var state = GameState(config: GameConfig())
        state.lines = 9
        state.level = 0
        state.applyLineClear(cleared: 1, clearedRows: [])
        #expect(state.lines == 10)
        #expect(state.level == 1)
    }
}
