import Testing
@testable import UI
@testable import Core

@Suite struct SidePanelStateTests {
    @Test func testHudStateIncludesHoldAndNextKinds() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.hold = .t
        state.nextQueue = [.i, .o, .s, .z, .l, .j]
        let hud = HUDState.from(state: state)
        #expect(hud.holdKind == .t)
        #expect(hud.nextKinds == [.i, .o, .s])
    }

    @Test func testHudStateIncludesStatusAndRulesetText() {
        let state = GameState(config: GameConfig(), seed: 1)
        let hud = HUDState.from(state: state, started: false)
        #expect(hud.statusText.contains("Status"))
        #expect(hud.rulesetText.contains("Rules"))
    }
}
