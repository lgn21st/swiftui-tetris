import XCTest
@testable import Core

final class LandingFlashTests: XCTestCase {
    func testHardDropSetsLandingFlashBlocks() {
        var state = GameState(config: GameConfig())
        state.apply(action: .hardDrop)
        XCTAssertEqual(state.landingFlashTimerMs, 120)
        XCTAssertEqual(state.landingFlashBlocks.count, 4)
        for (x, y) in state.landingFlashBlocks {
            XCTAssertTrue(state.board.cells[y][x].filled)
        }
    }
}
