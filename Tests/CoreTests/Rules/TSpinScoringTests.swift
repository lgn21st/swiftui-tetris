import Testing
@testable import Core

@Suite struct TSpinScoringTests {
    @Test func testTSpinFullUsesModernTable() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 1, clearedRows: [], tSpin: .full)
        #expect(state.score == 800)
    }
}
