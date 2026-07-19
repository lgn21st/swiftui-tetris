import Testing
@testable import Renderer
@testable import Core

@Suite struct RenderMappingTests {
    @Test func testRenderMappingPreservesBoardCellsWithoutKindProjection() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.board.cells[19][0] = Cell(filled: true, kind: .i)

        let renderState = RenderMapper.map(snapshot: state.snapshot())

        #expect(renderState.boardCells[19][0] == Cell(filled: true, kind: .i))
    }

    @Test func testRenderMappingIncludesActiveAndGhostAfterMove() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.activeMovedSinceSpawn = true
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(!renderState.activeBlocks.isEmpty)
        #expect(!renderState.ghostBlocks.isEmpty)
        #expect(renderState.ghostKind == .t)
    }

    @Test func testRenderMappingHidesGhostUntilActiveMoves() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.activeMovedSinceSpawn = false
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.ghostBlocks.isEmpty)
        #expect(renderState.ghostKind == nil)
    }

    @Test func testRenderMappingIncludesLockedCells() {
        var state = GameState(config: GameConfig())
        state.board.cells[19][0] = Cell(filled: true, kind: .i)
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.board[19][0] == .i)
    }

    @Test func testRenderMappingIncludesLandingFlashBlocks() {
        var state = GameState(config: GameConfig())
        state.setTimersForTesting(landingFlashTimerMs: GameConstants.landingFlashDurationMs)
        state.landingFlashBlocks = [(4, 10)]
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.flashBlocks.count == 1)
        #expect(renderState.flashBlocks[0].0 == 4)
        #expect(renderState.flashBlocks[0].1 == 10)
        #expect(abs((renderState.flashAlpha) - (1)) <= (0.01))
    }

    @Test func testRenderMappingComputesFlashAlphaFromTimer() {
        var state = GameState(config: GameConfig())
        state.setTimersForTesting(landingFlashTimerMs: GameConstants.landingFlashDurationMs / 2)
        state.landingFlashBlocks = [(4, 10)]
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(abs((renderState.flashAlpha) - (0.5)) <= (0.01))
    }

    @Test func testRenderMappingHidesActiveAndGhostDuringLineClearPause() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.setTimersForTesting(lineClearTimerMs: GameConstants.lineClearPauseMs)
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.activeBlocks.isEmpty)
        #expect(renderState.ghostBlocks.isEmpty)
        #expect(renderState.activeKind == nil)
        #expect(renderState.ghostKind == nil)
    }

    @Test func testRenderMappingIncludesLineClearRowsAndAlpha() {
        var state = GameState(config: GameConfig())
        state.setTimersForTesting(lineClearTimerMs: GameConstants.lineClearPauseMs / 2)
        state.lineClearRows = [18]
        state.lineClearScore = 400
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.lineClearRows == [18])
        #expect(abs((renderState.lineClearAlpha) - (0.5)) <= (0.01))
        #expect(renderState.scorePopups.count == 1)
        #expect(renderState.scorePopups[0].text == "+400")
    }

    @Test func testRenderMappingIncludesTSpinKindDuringLineClear() {
        var state = GameState(config: GameConfig(ruleset: .modern))
        state.applyLineClear(cleared: 1, clearedRows: [18], tSpin: .full)
        state.setTimersForTesting(lineClearTimerMs: GameConstants.lineClearPauseMs / 2)
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.tSpinKind == .full)
        #expect(abs((renderState.tSpinAlpha) - (0.5)) <= (0.01))
    }

    @Test func testRenderMappingCopiesPauseAndGameOverFlags() {
        var state = GameState(config: GameConfig())
        state.paused = true
        state.gameOver = true
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.isPaused)
        #expect(renderState.isGameOver)
    }

    @Test func testRenderMappingComputesActivePulse() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.setTimersForTesting(dropTimerMs: 0)
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(abs((renderState.activePulse) - (0)) <= (0.001))
    }

    @Test func testRenderMappingComputesActivePulseAtMidInterval() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.setTimersForTesting(dropTimerMs: 500)
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(abs((renderState.activePulse) - (1)) <= (0.001))
    }

    @Test func testRenderMappingHidesGhostDuringLockDelay() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .l, x: 4, y: 0)
        state.updateGhostCache()
        state.setTimersForTesting(lockTimerMs: GameConstants.lockDelayMs / 2)
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.ghostBlocks.isEmpty)
        #expect(renderState.ghostKind == nil)
    }

    @Test func testRenderMappingHidesGhostWhenGroundedBeforeLockTimer() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .o, x: 4, y: Board.height - 2)
        state.updateGhostCache()
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.ghostBlocks.isEmpty)
        #expect(renderState.ghostKind == nil)
    }



    @Test func testRenderMappingFlagsGroundedWhenActiveCannotMoveDown() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .o, x: 4, y: Board.height - 2)
        state.updateGhostCache()
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        #expect(renderState.isGrounded)
    }
}
