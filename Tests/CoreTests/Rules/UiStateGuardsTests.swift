import XCTest
@testable import Core

final class UiStateGuardsTests: XCTestCase {
    func testGameOverBlocksActionsExceptRestart() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.gameOver = true
        let startX = state.active.x
        state.apply(action: .moveRight)
        XCTAssertEqual(state.active.x, startX)
        state.restart(seed: 2)
        XCTAssertFalse(state.gameOver)
    }

    func testPausedBlocksTick() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.paused = true
        let startY = state.active.y
        state.tick(elapsedMs: 1000, softDrop: false)
        XCTAssertEqual(state.active.y, startY)
    }
}
