import XCTest
@testable import Core

final class ModernRulesTests: XCTestCase {
    func testComboIncreasesOnConsecutiveClears() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 1)
        XCTAssertEqual(state.combo, 0)
        state.applyLineClear(cleared: 1)
        XCTAssertEqual(state.combo, 1)
    }

    func testBackToBackAppliesForTetris() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 4)
        XCTAssertTrue(state.backToBack)
    }

    func testComboResetsOnZeroClear() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 1)
        state.applyLineClear(cleared: 0)
        XCTAssertEqual(state.combo, -1)
        XCTAssertFalse(state.backToBack)
    }
}
