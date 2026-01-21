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

    func testDiagnosticsStateReportsActiveAndGhost() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 1, y: 2)
        state.updateGhostCache()
        let diag = HUDDiagnosticsState.from(state: state)
        let ghostBlocks = state.ghostBlocks()
        XCTAssertEqual(diag.activeText, "Active: i @ (1, 2)")
        XCTAssertEqual(diag.ghostText, "Ghost blocks: \(ghostBlocks.count)")
        XCTAssertEqual(diag.ghostBoundsText, ghostBoundsDescription(ghostBlocks))
    }

    private func ghostBoundsDescription(_ blocks: [(Int, Int)]) -> String {
        guard let first = blocks.first else { return "Ghost bounds: -" }
        var minX = first.0
        var maxX = first.0
        var minY = first.1
        var maxY = first.1
        for (x, y) in blocks.dropFirst() {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
        return "Ghost bounds: x[\(minX)..\(maxX)] y[\(minY)..\(maxY)]"
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
