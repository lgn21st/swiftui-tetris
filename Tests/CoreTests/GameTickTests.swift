import XCTest
@testable import Core

final class GameTickTests: XCTestCase {
    func testLineClearPauseBlocksGravity() {
        var state = GameState(config: GameConfig())
        state.lineClearTimerMs = 100
        state.dropTimerMs = 200
        state.tick(elapsedMs: 50, softDrop: false)
        XCTAssertEqual(state.dropTimerMs, 200)
        XCTAssertEqual(state.lineClearTimerMs, 50)
    }

    func testSoftDropGraceExpires() {
        var state = GameState(config: GameConfig())
        state.activateSoftDrop()
        XCTAssertTrue(state.softDropActive)
        state.tick(elapsedMs: 150, softDrop: false)
        XCTAssertFalse(state.softDropActive)
    }

    func testLockDelayLocksPieceAfterThreshold() {
        var config = GameConfig()
        config.lockDelayMs = 100
        var state = GameState(config: config)
        state.active = Tetromino(kind: .o, x: 0, y: Board.height - 2)
        state.tick(elapsedMs: 50, softDrop: false)
        XCTAssertEqual(state.lockTimerMs, 50)
        state.tick(elapsedMs: 50, softDrop: false)
        XCTAssertEqual(state.lockTimerMs, 0)
        XCTAssertTrue(state.board.cells[Board.height - 1][1].filled)
    }

    func testGravityAdvancesAfterInterval() {
        var config = GameConfig()
        config.baseDropMs = 100
        var state = GameState(config: config)
        let startY = state.active.y
        state.tick(elapsedMs: 100, softDrop: false)
        XCTAssertEqual(state.active.y, startY + 1)
    }
}
