import XCTest
@testable import UI
@testable import Core

final class HUDDetailTests: XCTestCase {
    func testHudLockBarRatio() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.lockTimerMs = 225
        state.config.lockDelayMs = 450
        let hud = HUDState.from(state: state)
        XCTAssertEqual(hud.lockBarRatio, 0.5, accuracy: 0.001)
        XCTAssertTrue(hud.isClassicRuleset)
    }

    func testHudLockWarningPulseWhenActive() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.config.lockDelayMs = 1000
        state.lockTimerMs = 850
        let hud = HUDState.from(state: state)
        XCTAssertTrue(hud.lockWarningActive)
        XCTAssertEqual(hud.lockWarningPulse, 0.55, accuracy: 0.001)
    }

    func testHudLockWarningPulseWhenInactive() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.config.lockDelayMs = 1000
        state.lockTimerMs = 200
        let hud = HUDState.from(state: state)
        XCTAssertFalse(hud.lockWarningActive)
        XCTAssertEqual(hud.lockWarningPulse, 0, accuracy: 0.001)
    }
}
