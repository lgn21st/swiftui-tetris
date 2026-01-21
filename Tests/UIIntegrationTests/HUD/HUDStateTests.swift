import XCTest
@testable import UI
@testable import Core

final class HUDStateTests: XCTestCase {
    func testHudStateFormatsValues() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.score = 120
        state.level = 2
        state.lines = 11
        let hud = HUDState.from(state: state)
        XCTAssertEqual(hud.scoreText, "Score: 120")
        XCTAssertEqual(hud.levelText, "Level: 2")
        XCTAssertEqual(hud.linesText, "Lines: 11")
    }

    func testHudHoldStatus() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.canHold = true
        let hud = HUDState.from(state: state)
        XCTAssertEqual(hud.holdText, "Hold: Ready")
    }

    func testHudLockWarningActivatesNearLock() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.lockTimerMs = 400
        let hud = HUDState.from(state: state)
        XCTAssertTrue(hud.lockWarningActive)
    }

    func testHudLockWarningInactiveEarly() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.lockTimerMs = 100
        let hud = HUDState.from(state: state)
        XCTAssertFalse(hud.lockWarningActive)
    }

    func testHudRulesetTextReflectsConfig() {
        let classic = GameState(config: GameConfig(ruleset: .classic), seed: 1)
        XCTAssertEqual(HUDState.from(state: classic).rulesetText, "Rules: Classic")

        let modern = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        XCTAssertEqual(HUDState.from(state: modern).rulesetText, "Rules: Modern")
    }

    func testHudStatusText() {
        var state = GameState(config: GameConfig(), seed: 1)
        XCTAssertEqual(HUDState.from(state: state).statusText, "Status: Playing")

        state.paused = true
        XCTAssertEqual(HUDState.from(state: state).statusText, "Status: Paused")

        state.paused = false
        state.gameOver = true
        XCTAssertEqual(HUDState.from(state: state).statusText, "Status: Game Over")
    }

    func testHudStatusTextBeforeStart() {
        let state = GameState(config: GameConfig(), seed: 1)
        XCTAssertEqual(HUDState.from(state: state, started: false).statusText, "Status: Ready")
    }
}
