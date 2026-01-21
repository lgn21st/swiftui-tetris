import XCTest
@testable import Core

final class ScoringTests: XCTestCase {
    func testClassicSingleLineScoreAtLevelZero() {
        var state = GameState(config: GameConfig())
        state.applyLineClear(cleared: 1, clearedRows: [])
        XCTAssertEqual(state.score, 40)
        XCTAssertEqual(state.lines, 1)
        XCTAssertEqual(state.level, 0)
    }

    func testClassicTetrisScoreAtLevelTwo() {
        var state = GameState(config: GameConfig())
        state.level = 2
        state.applyLineClear(cleared: 4, clearedRows: [])
        XCTAssertEqual(state.score, 1200 * 3)
    }

    func testLevelAdvancesEveryTenLines() {
        var state = GameState(config: GameConfig())
        state.lines = 9
        state.level = 0
        state.applyLineClear(cleared: 1, clearedRows: [])
        XCTAssertEqual(state.lines, 10)
        XCTAssertEqual(state.level, 1)
    }
}
