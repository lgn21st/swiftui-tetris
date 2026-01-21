import XCTest
@testable import Renderer
@testable import Core

final class RenderMappingTests: XCTestCase {
    func testRenderMappingIncludesActiveAndGhost() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        let renderState = RenderMapper.map(state: state)
        XCTAssertFalse(renderState.activeBlocks.isEmpty)
        XCTAssertFalse(renderState.ghostBlocks.isEmpty)
    }

    func testRenderMappingIncludesLockedCells() {
        var state = GameState(config: GameConfig())
        state.board.cells[19][0] = Cell(filled: true, kind: .i)
        let renderState = RenderMapper.map(state: state)
        XCTAssertEqual(renderState.board[19][0], .i)
    }

    func testRenderMappingIncludesLandingFlash() {
        var state = GameState(config: GameConfig())
        state.landingFlashTimerMs = 120
        state.landingFlashBlocks = [(4, 10)]
        let renderState = RenderMapper.map(state: state)
        XCTAssertEqual(renderState.flashBlocks.count, 1)
        XCTAssertEqual(renderState.flashBlocks[0].0, 4)
        XCTAssertEqual(renderState.flashBlocks[0].1, 10)
    }

    func testRenderMappingComputesFlashAlpha() {
        var state = GameState(config: GameConfig())
        state.landingFlashTimerMs = 60
        state.landingFlashBlocks = [(4, 10)]
        let renderState = RenderMapper.map(state: state)
        XCTAssertEqual(renderState.flashAlpha, 0.5, accuracy: 0.01)
    }

    func testRenderMappingHidesActiveAndGhostDuringLineClearPause() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.lineClearTimerMs = 180
        let renderState = RenderMapper.map(state: state)
        XCTAssertTrue(renderState.activeBlocks.isEmpty)
        XCTAssertTrue(renderState.ghostBlocks.isEmpty)
        XCTAssertNil(renderState.activeKind)
        XCTAssertNil(renderState.ghostKind)
    }

    func testRenderMappingCopiesPauseAndGameOverFlags() {
        var state = GameState(config: GameConfig())
        state.paused = true
        state.gameOver = true
        let renderState = RenderMapper.map(state: state)
        XCTAssertTrue(renderState.isPaused)
        XCTAssertTrue(renderState.isGameOver)
    }

    func testRenderMappingIncludesSoftDropTrailWhenActive() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.softDropActive = true
        let renderState = RenderMapper.map(state: state)
        XCTAssertFalse(renderState.softDropTrailBlocks.isEmpty)
        XCTAssertEqual(renderState.softDropTrailKind, .t)
    }

    func testRenderMappingOmitsSoftDropTrailWhenInactive() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.updateGhostCache()
        state.softDropActive = false
        let renderState = RenderMapper.map(state: state)
        XCTAssertTrue(renderState.softDropTrailBlocks.isEmpty)
        XCTAssertNil(renderState.softDropTrailKind)
    }

    func testRenderMappingComputesActivePulse() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.dropTimerMs = 0
        let renderState = RenderMapper.map(state: state)
        XCTAssertEqual(renderState.activePulse, 0, accuracy: 0.001)
    }

    func testRenderMappingComputesActivePulseAtMidInterval() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.dropTimerMs = 500
        let renderState = RenderMapper.map(state: state)
        XCTAssertEqual(renderState.activePulse, 1, accuracy: 0.001)
    }
}
