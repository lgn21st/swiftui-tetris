import XCTest
@testable import UI
@testable import Core

final class HUDDiagnosticsStateTests: XCTestCase {
    func testDiagnosticsStateIncludesLastInputAndHint() {
        let state = GameState(config: GameConfig(), seed: 1)
        let diag = HUDDiagnosticsState.from(state: state, lastInput: .rotateCw)
        XCTAssertEqual(diag.lastInputText, "Last input: Rotate CW")
        XCTAssertEqual(diag.hintText, "Keys: ←/→ Move · ↑ Rotate · ↓ Soft · Space Hard · C Hold · P Pause")
    }

    func testDiagnosticsStateIncludesGroundedAndLockResets() {
        var state = GameState(config: GameConfig(lockResetLimit: 15), seed: 1)
        state.lockResetCount = 3
        let diag = HUDDiagnosticsState.from(state: state)
        XCTAssertEqual(diag.lockResetsText, "Lock resets: 12/15")
        XCTAssertEqual(diag.groundedText, "Grounded: No")
    }

    func testDiagnosticsStateShowsComboAndB2BForModernRules() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.combo = 2
        state.backToBack = true
        let diag = HUDDiagnosticsState.from(state: state)
        XCTAssertEqual(diag.comboText, "Combo: 2")
        XCTAssertEqual(diag.b2bText, "B2B: Yes")
        XCTAssertFalse(diag.isClassicRuleset)
    }
}
