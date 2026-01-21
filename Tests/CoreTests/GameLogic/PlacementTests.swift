import XCTest
@testable import Core

final class PlacementTests: XCTestCase {
    func testCanPlaceAllowsEmptyBoard() {
        let board = Board()
        let piece = Tetromino(kind: .t, x: 3, y: 0)
        XCTAssertTrue(board.canPlace(piece: piece, x: 3, y: 0, rotation: .north))
    }

    func testCanPlaceRejectsOverlapInRotation() {
        var board = Board()
        board.cells[1][1] = Cell(filled: true, kind: .z)
        let piece = Tetromino(kind: .t, x: 0, y: 0)
        XCTAssertFalse(board.canPlace(piece: piece, x: 0, y: 0, rotation: .north))
    }

    func testCanPlaceRejectsOutOfBounds() {
        let board = Board()
        let piece = Tetromino(kind: .i, x: 8, y: 0)
        XCTAssertFalse(board.canPlace(piece: piece, x: 8, y: 0, rotation: .north))
    }
}
