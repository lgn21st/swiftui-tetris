import Testing
@testable import Core

@Suite struct ModernRulesTests {
    @Test func testComboIncreasesOnConsecutiveClears() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 1, clearedRows: [])
        #expect(state.combo == 0)
        state.applyLineClear(cleared: 1, clearedRows: [])
        #expect(state.combo == 1)
    }

    @Test func testBackToBackAppliesForTetris() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 4, clearedRows: [])
        #expect(state.backToBack)
    }

    @Test func testComboResetsOnZeroClear() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 1, clearedRows: [])
        state.applyLineClear(cleared: 0, clearedRows: [])
        #expect(state.combo == -1)
        #expect(!state.backToBack)
    }
}
