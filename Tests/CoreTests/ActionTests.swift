import Testing
@testable import Core

@Suite struct ActionTests {
    @Test func testApplyActionSoftDropAddsScore() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.score = 0
        state.apply(action: .softDrop)
        #expect(state.score == 1)
    }

    @Test func testApplyActionHardDropLocksAndScores() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.score = 0
        state.apply(action: .hardDrop)
        #expect(state.score > 0)
        #expect(state.dropTimerMs == 0)
    }

    @Test func testApplyActionPauseToggles() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.apply(action: .pause)
        #expect(state.paused)
        state.apply(action: .pause)
        #expect(!state.paused)
    }

    @Test func testPauseClearsSoftDropState() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.softDropActive = true
        state.setTimersForTesting(softDropTimeoutMs: 120)
        state.apply(action: .pause)
        #expect(state.paused)
        #expect(!state.softDropActive)
        #expect(state.softDropTimeoutMs == 0)
    }
}
