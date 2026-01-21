import XCTest
@testable import Core

final class TSpinScoringTests: XCTestCase {
    func testTSpinFullUsesModernTable() {
        var config = GameConfig()
        config.ruleset = .modern
        var state = GameState(config: config, seed: 1)
        state.applyLineClear(cleared: 1, tSpin: .full)
        XCTAssertEqual(state.score, 800)
    }
}
