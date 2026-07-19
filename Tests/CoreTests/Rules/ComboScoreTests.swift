import Testing
@testable import Core

@Suite struct ComboScoreTests {
    @Test func testComboAddsBonusPoints() {
        var config = GameConfig()
        config.ruleset = .modern
        config.rules = RulesConfig(comboBase: 50)
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 1, clearedRows: [])
        let firstScore = state.score
        state.applyLineClear(cleared: 1, clearedRows: [])
        #expect(state.combo == 1)
        #expect(state.score == firstScore + (40 * 1 + 50))
    }

    @Test func testLineClearEventScoreIncludesComboBonus() {
        var config = GameConfig(ruleset: .modern)
        config.rules = RulesConfig(comboBase: 50)
        var state = GameState(config: config, seed: 1)

        state.applyLineClear(cleared: 1, clearedRows: [19])
        state.applyLineClear(cleared: 1, clearedRows: [19])

        #expect(state.combo == 1)
        #expect(state.lineClearScore == 90)
        #expect(state.score == 130)
    }
}
