import Testing
@testable import UI
@testable import Core

@Suite struct HUDStateTests {
    @Test func testHudStateFormatsValues() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.score = 120
        state.level = 2
        state.lines = 11
        let hud = HUDState.from(state: state.snapshot())
        #expect(hud.scoreText == "Score: 120")
        #expect(hud.levelText == "Level: 2")
        #expect(hud.linesText == "Lines: 11")
    }

    @Test func testHudHoldStatus() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.canHold = true
        let hud = HUDState.from(state: state.snapshot())
        #expect(hud.holdText == "Hold: Ready")
    }

    @Test func testHudLockWarningActivatesNearLock() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.setTimersForTesting(lockTimerMs: 400)
        let hud = HUDState.from(state: state.snapshot())
        #expect(hud.lockWarningActive)
    }

    @Test func testHudLockWarningInactiveEarly() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.setTimersForTesting(lockTimerMs: 100)
        let hud = HUDState.from(state: state.snapshot())
        #expect(!hud.lockWarningActive)
    }

    @Test func testHudRulesetTextReflectsConfig() {
        let classic = GameState(config: GameConfig(ruleset: .classic), seed: 1)
        #expect(HUDState.from(state: classic.snapshot()).rulesetText == "Rules: Classic")

        let modern = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        #expect(HUDState.from(state: modern.snapshot()).rulesetText == "Rules: Modern")
    }

    @Test func testHudStatusText() {
        var state = GameState(config: GameConfig(), seed: 1)
        #expect(HUDState.from(state: state.snapshot()).statusText == "Status: Playing")

        state.paused = true
        #expect(HUDState.from(state: state.snapshot()).statusText == "Status: Paused")

        state.paused = false
        state.gameOver = true
        #expect(HUDState.from(state: state.snapshot()).statusText == "Status: Game Over")
    }

    @Test func testHudStatusTextBeforeStart() {
        let state = GameState(config: GameConfig(), seed: 1)
        #expect(HUDState.from(state: state.snapshot(), started: false).statusText == "Status: Ready")
    }

    @Test func testHudNextKindsShowsThree() {
        let state = GameState(config: GameConfig(), seed: 1)
        let hud = HUDState.from(state: state.snapshot())
        #expect(hud.nextKinds.count == 3)
    }
}
