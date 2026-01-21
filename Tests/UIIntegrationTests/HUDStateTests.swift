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

    func testHudHintText() {
        let state = GameState(config: GameConfig(), seed: 1)
        let hud = HUDState.from(state: state)
        XCTAssertEqual(hud.hintText, "Keys: ←/→ Move · ↑ Rotate · ↓ Soft · Space Hard · C Hold · P Pause · S Settings · M Mute")
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

    func testHudLastInputAndSfxLabels() {
        let state = GameState(config: GameConfig(), seed: 1)
        var settings = SettingsState()
        settings.volume = 0.7
        let hud = HUDState.from(state: state, settings: settings, lastInput: .rotateCw)
        XCTAssertEqual(hud.lastInputText, "Last input: Rotate CW")
        XCTAssertEqual(hud.sfxText, "SFX: 70%")

        settings.muted = true
        let mutedHud = HUDState.from(state: state, settings: settings, lastInput: nil)
        XCTAssertEqual(mutedHud.lastInputText, "Last input: None")
        XCTAssertEqual(mutedHud.sfxText, "SFX: Muted")
    }

    func testHudGroundedAndLockResetsText() {
        var state = GameState(config: GameConfig(lockResetLimit: 15), seed: 1)
        state.lockResetCount = 3
        let hud = HUDState.from(state: state)
        XCTAssertEqual(hud.lockResetsText, "Lock resets: 12/15")
        XCTAssertEqual(hud.groundedText, "Grounded: No")
    }
}
