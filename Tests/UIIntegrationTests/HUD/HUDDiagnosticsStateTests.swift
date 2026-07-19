import Testing
@testable import UI
@testable import Core

@Suite struct HUDDiagnosticsStateTests {
    @Test func testDiagnosticsStateIncludesLastInputAndHint() {
        let state = GameState(config: GameConfig(), seed: 1)
        let diag = HUDDiagnosticsState.from(state: state.snapshot(), lastInput: .rotateCw)
        #expect(diag.lastInputText == "Last input: Rotate CW")
        #expect(diag.hintText == "Keys: ←/→ Move · ↑ Rotate · ↓ Soft · Space Hard · C Hold · P Pause")
    }

    @Test func testDiagnosticsStateIncludesGroundedAndLockResets() {
        var state = GameState(config: GameConfig(lockResetLimit: 15), seed: 1)
        state.setTimersForTesting(lockResetCount: 3)
        let diag = HUDDiagnosticsState.from(state: state.snapshot())
        #expect(diag.lockResetsText == "Lock resets: 12/15")
        #expect(diag.groundedText == "Grounded: No")
    }

    @Test func testDiagnosticsStateReportsActiveAndGhost() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 1, y: 2)
        state.updateGhostCache()
        let diag = HUDDiagnosticsState.from(state: state.snapshot())
        let ghostBlocks = state.ghostBlocks()
        #expect(diag.activeText == "Active: i @ (1, 2)")
        #expect(diag.ghostText == "Ghost blocks: \(ghostBlocks.count)")
        #expect(diag.ghostBoundsText == ghostBoundsDescription(ghostBlocks))
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

    @Test func testDiagnosticsStateShowsComboAndB2BForModernRules() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.combo = 2
        state.backToBack = true
        let diag = HUDDiagnosticsState.from(state: state.snapshot())
        #expect(diag.comboText == "Combo: 2")
        #expect(diag.b2bText == "B2B: Yes")
        #expect(!diag.isClassicRuleset)
    }
}
