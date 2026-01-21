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
}
