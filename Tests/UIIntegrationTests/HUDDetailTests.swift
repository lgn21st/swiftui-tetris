import XCTest
@testable import UI
@testable import Core

final class HUDDetailTests: XCTestCase {
    func testHudShowsComboAndB2B() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.combo = 2
        state.backToBack = true
        let hud = HUDState.from(state: state)
        XCTAssertEqual(hud.comboText, "Combo: 2")
        XCTAssertEqual(hud.b2bText, "B2B: Yes")
    }

    func testHudLockBarRatio() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.lockTimerMs = 225
        state.config.lockDelayMs = 450
        let hud = HUDState.from(state: state)
        XCTAssertEqual(hud.lockBarRatio, 0.5, accuracy: 0.001)
    }
}
