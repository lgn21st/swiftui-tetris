import XCTest
@testable import UI
@testable import Core

final class SidePanelStateTests: XCTestCase {
    func testHudStateIncludesHoldAndNextKinds() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.hold = .t
        state.nextQueue = [.i, .o, .s, .z, .l, .j]
        let hud = HUDState.from(state: state)
        XCTAssertEqual(hud.holdKind, .t)
        XCTAssertEqual(hud.nextKinds, [.i, .o, .s, .z, .l])
    }
}
