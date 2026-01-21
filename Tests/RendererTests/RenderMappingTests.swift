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
}
