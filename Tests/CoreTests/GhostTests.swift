import XCTest
@testable import Core

final class GhostTests: XCTestCase {
    func testGhostFallsToBottom() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.updateGhostCache()
        let ghost = state.ghostBlocks()
        let maxY = ghost.map { $0.1 }.max() ?? 0
        XCTAssertEqual(maxY, Board.height - 1)
    }

    func testGhostStopsAboveStack() {
        var state = GameState(config: GameConfig())
        state.board.cells[Board.height - 1][3] = Cell(filled: true, kind: .z)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.updateGhostCache()
        let ghost = state.ghostBlocks()
        let maxY = ghost.map { $0.1 }.max() ?? 0
        XCTAssertEqual(maxY, Board.height - 2)
    }
}
