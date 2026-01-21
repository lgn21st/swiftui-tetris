import XCTest
@testable import Core

final class GameStateSnapshotTests: XCTestCase {
    func testSnapshotCopiesCoreFields() {
        var state = GameState(config: GameConfig())
        state.paused = true
        state.gameOver = true
        state.dropTimerMs = 320
        state.applyLineClear(cleared: 1, clearedRows: [18], tSpin: .full)
        state.score = 1200
        state.level = 3
        state.lines = 15
        state.landingFlashTimerMs = 60
        state.landingFlashBlocks = [(4, 10)]
        state.softDropActive = true

        let snapshot = state.snapshot()

        XCTAssertEqual(snapshot.score, 1200)
        XCTAssertEqual(snapshot.level, 3)
        XCTAssertEqual(snapshot.lines, 15)
        XCTAssertTrue(snapshot.paused)
        XCTAssertTrue(snapshot.gameOver)
        XCTAssertEqual(snapshot.dropTimerMs, 320)
        XCTAssertEqual(snapshot.lineClearTimerMs, GameConstants.lineClearPauseMs)
        XCTAssertEqual(snapshot.lineClearRows, [18])
        XCTAssertEqual(snapshot.lineClearScore, 40)
        XCTAssertEqual(snapshot.lastLineClearTSpin, .full)
        XCTAssertEqual(snapshot.landingFlashTimerMs, 60)
        assertBlocksEqual(snapshot.landingFlashBlocks, [(4, 10)])
        XCTAssertTrue(snapshot.softDropActive)
    }

    func testSnapshotIncludesGhostBlocks() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.updateGhostCache()

        let snapshot = state.snapshot()

        assertBlocksEqual(snapshot.ghostBlocks, state.ghostBlocks())
    }

    private func assertBlocksEqual(_ lhs: [(Int, Int)], _ rhs: [(Int, Int)]) {
        XCTAssertEqual(lhs.count, rhs.count)
        for (index, value) in lhs.enumerated() {
            XCTAssertEqual(value.0, rhs[index].0)
            XCTAssertEqual(value.1, rhs[index].1)
        }
    }
}
