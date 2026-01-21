import XCTest
@testable import Renderer
@testable import Core

final class RenderMappingTests: XCTestCase {
    func testRenderMappingIncludesActiveAndGhost() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertFalse(renderState.activeBlocks.isEmpty)
        XCTAssertFalse(renderState.ghostBlocks.isEmpty)
    }

    func testRenderMappingIncludesLockedCells() {
        var state = GameState(config: GameConfig())
        state.board.cells[19][0] = Cell(filled: true, kind: .i)
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertEqual(renderState.board[19][0], .i)
    }

    func testRenderMappingIncludesLandingFlash() {
        var state = GameState(config: GameConfig())
        state.landingFlashTimerMs = GameConstants.landingFlashDurationMs
        state.landingFlashBlocks = [(4, 10)]
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertEqual(renderState.flashBlocks.count, 1)
        XCTAssertEqual(renderState.flashBlocks[0].0, 4)
        XCTAssertEqual(renderState.flashBlocks[0].1, 10)
    }

    func testRenderMappingComputesFlashAlpha() {
        var state = GameState(config: GameConfig())
        state.landingFlashTimerMs = GameConstants.landingFlashDurationMs / 2
        state.landingFlashBlocks = [(4, 10)]
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertEqual(renderState.flashAlpha, 0.5, accuracy: 0.01)
    }

    func testRenderMappingHidesActiveAndGhostDuringLineClearPause() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.lineClearTimerMs = GameConstants.lineClearPauseMs
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertTrue(renderState.activeBlocks.isEmpty)
        XCTAssertTrue(renderState.ghostBlocks.isEmpty)
        XCTAssertNil(renderState.activeKind)
        XCTAssertNil(renderState.ghostKind)
    }

    func testRenderMappingIncludesLineClearRowsAndAlpha() {
        var state = GameState(config: GameConfig())
        state.lineClearTimerMs = GameConstants.lineClearPauseMs / 2
        state.lineClearRows = [18]
        state.lineClearScore = 400
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertEqual(renderState.lineClearRows, [18])
        XCTAssertEqual(renderState.lineClearAlpha, 0.5, accuracy: 0.01)
        XCTAssertEqual(renderState.scorePopups.count, 1)
        XCTAssertEqual(renderState.scorePopups[0].text, "+400")
    }

    func testRenderMappingIncludesTSpinKindDuringLineClear() {
        var state = GameState(config: GameConfig(ruleset: .modern))
        state.applyLineClear(cleared: 1, clearedRows: [18], tSpin: .full)
        state.lineClearTimerMs = GameConstants.lineClearPauseMs / 2
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertEqual(renderState.tSpinKind, .full)
        XCTAssertEqual(renderState.tSpinAlpha, 0.5, accuracy: 0.01)
    }

    func testRenderMappingCopiesPauseAndGameOverFlags() {
        var state = GameState(config: GameConfig())
        state.paused = true
        state.gameOver = true
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertTrue(renderState.isPaused)
        XCTAssertTrue(renderState.isGameOver)
    }

    func testRenderMappingIncludesSoftDropTrailWhenActive() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.softDropActive = true
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertFalse(renderState.softDropTrailBlocks.isEmpty)
        XCTAssertEqual(renderState.softDropTrailKind, .t)
    }

    func testRenderMappingOmitsSoftDropTrailWhenInactive() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.softDropActive = false
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertTrue(renderState.softDropTrailBlocks.isEmpty)
        XCTAssertNil(renderState.softDropTrailKind)
    }

    func testRenderMappingComputesActivePulse() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.dropTimerMs = 0
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertEqual(renderState.activePulse, 0, accuracy: 0.001)
    }

    func testRenderMappingComputesActivePulseAtMidInterval() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.dropTimerMs = 500
        let renderState = RenderMapper.map(snapshot: state.snapshot())
        XCTAssertEqual(renderState.activePulse, 1, accuracy: 0.001)
    }
}
