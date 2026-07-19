import Testing
@testable import Core

@Suite struct GhostTests {
    @Test func testGhostFallsToBottom() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.updateGhostCache()
        let ghost = state.ghostBlocks()
        let maxY = ghost.map { $0.1 }.max() ?? 0
        #expect(maxY == Board.height - 1)
    }

    @Test func testGhostStopsAboveStack() {
        var state = GameState(config: GameConfig())
        state.board.cells[Board.height - 1][3] = Cell(filled: true, kind: .z)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.updateGhostCache()
        let ghost = state.ghostBlocks()
        let maxY = ghost.map { $0.1 }.max() ?? 0
        #expect(maxY == Board.height - 2)
    }

    @Test func testSpawnNextRefreshesGhostForNewActivePiece() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.nextQueue = [.o, .t, .s, .z, .j, .l]

        state.spawnNext()

        var expectedY = state.active.y
        while state.board.canPlace(
            piece: state.active,
            x: state.active.x,
            y: expectedY + 1,
            rotation: state.active.rotation
        ) {
            expectedY += 1
        }
        let expected = state.active.blocks(rotation: state.active.rotation).map {
            (state.active.x + $0.0, expectedY + $0.1)
        }
        #expect(state.ghostBlocks().map { [$0.0, $0.1] } == expected.map { [$0.0, $0.1] })
    }
}
