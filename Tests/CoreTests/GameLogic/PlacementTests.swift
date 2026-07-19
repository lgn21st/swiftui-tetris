import Testing
@testable import Core

@Suite struct PlacementTests {
    @Test func testCanPlaceAllowsEmptyBoard() {
        let board = Board()
        let piece = Tetromino(kind: .t, x: 3, y: 0)
        #expect(board.canPlace(piece: piece, x: 3, y: 0, rotation: .north))
    }

    @Test func testCanPlaceRejectsOverlapInRotation() {
        var board = Board()
        board.cells[1][1] = Cell(filled: true, kind: .z)
        let piece = Tetromino(kind: .t, x: 0, y: 0)
        #expect(!board.canPlace(piece: piece, x: 0, y: 0, rotation: .north))
    }

    @Test func testCanPlaceRejectsOutOfBounds() {
        let board = Board()
        let piece = Tetromino(kind: .i, x: 8, y: 0)
        #expect(!board.canPlace(piece: piece, x: 8, y: 0, rotation: .north))
    }
}
