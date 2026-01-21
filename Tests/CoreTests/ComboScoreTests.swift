import XCTest
@testable import Core

final class ComboScoreTests: XCTestCase {
    func testComboAddsBonusPoints() {
        var config = GameConfig()
        config.ruleset = .modern
        config.rules = RulesConfig(comboBase: 50)
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 1)
        let firstScore = state.score
        state.applyLineClear(cleared: 1)
        XCTAssertEqual(state.combo, 1)
        XCTAssertEqual(state.score, firstScore + (40 * 1 + 50))
    }
}
