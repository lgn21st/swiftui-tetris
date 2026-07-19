import Testing
@testable import Core

@Suite struct GameTickTests {
    @Test func testLineClearPauseBlocksGravity() {
        var state = GameState(config: GameConfig())
        state.setTimersForTesting(dropTimerMs: 200, lineClearTimerMs: 100)
        state.tick(elapsedMs: 50, softDrop: false)
        #expect(state.dropTimerMs == 200)
        #expect(state.lineClearTimerMs == 50)
    }

    @Test func testSoftDropGraceExpires() {
        var state = GameState(config: GameConfig())
        state.activateSoftDrop()
        #expect(state.softDropActive)
        state.tick(elapsedMs: GameConstants.softDropGraceMs, softDrop: false)
        #expect(!state.softDropActive)
    }

    @Test func testLockDelayLocksPieceAfterThreshold() {
        var config = GameConfig()
        config.lockDelayMs = 100
        var state = GameState(config: config)
        state.active = Tetromino(kind: .o, x: 0, y: Board.height - 2)
        state.tick(elapsedMs: 50, softDrop: false)
        #expect(state.lockTimerMs == 50)
        state.tick(elapsedMs: 50, softDrop: false)
        #expect(state.lockTimerMs == 0)
        #expect(state.board.cells[Board.height - 1][1].filled)
    }

    @Test func testGravityAdvancesAfterInterval() {
        var config = GameConfig()
        config.baseDropMs = 100
        var state = GameState(config: config)
        let startY = state.active.y
        state.tick(elapsedMs: 100, softDrop: false)
        #expect(state.active.y == startY + 1)
    }

    @Test func testGravityUsesLevelInterval() {
        var config = GameConfig()
        config.baseDropMs = 1000
        var state = GameState(config: config)
        state.level = 1
        let startY = state.active.y
        state.tick(elapsedMs: 800, softDrop: false)
        #expect(state.active.y == startY + 1)
    }

}
