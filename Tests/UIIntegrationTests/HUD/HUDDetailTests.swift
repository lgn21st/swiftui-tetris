import Testing
@testable import UI
@testable import Core

@Suite struct HUDDetailTests {
    @Test func testHudLockBarRatio() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.setTimersForTesting(lockTimerMs: 225)
        state.config.lockDelayMs = 450
        let hud = HUDState.from(state: state)
        #expect(abs((hud.lockBarRatio) - (0.5)) <= (0.001))
        #expect(hud.isClassicRuleset)
    }

    @Test func testHudLockWarningPulseWhenActive() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.config.lockDelayMs = 1000
        state.setTimersForTesting(lockTimerMs: 850)
        let hud = HUDState.from(state: state)
        #expect(hud.lockWarningActive)
        #expect(abs((hud.lockWarningPulse) - (0.55)) <= (0.001))
    }

    @Test func testHudLockWarningPulseWhenInactive() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.config.lockDelayMs = 1000
        state.setTimersForTesting(lockTimerMs: 200)
        let hud = HUDState.from(state: state)
        #expect(!hud.lockWarningActive)
        #expect(abs((hud.lockWarningPulse) - (0)) <= (0.001))
    }
}
