import XCTest
@testable import Core

final class BoardLogicTests: XCTestCase {
    func testIsInsideBounds() {
        let board = Board()
        XCTAssertTrue(board.isInside(x: 0, y: 0))
        XCTAssertTrue(board.isInside(x: 9, y: 19))
        XCTAssertFalse(board.isInside(x: -1, y: 0))
        XCTAssertFalse(board.isInside(x: 10, y: 0))
        XCTAssertFalse(board.isInside(x: 0, y: -1))
        XCTAssertFalse(board.isInside(x: 0, y: 20))
    }

    func testIsOccupiedTreatsOutOfBoundsAsFilled() {
        let board = Board()
        XCTAssertTrue(board.isOccupied(x: -1, y: 0))
        XCTAssertTrue(board.isOccupied(x: 10, y: 0))
        XCTAssertTrue(board.isOccupied(x: 0, y: -1))
        XCTAssertTrue(board.isOccupied(x: 0, y: 20))
        XCTAssertFalse(board.isOccupied(x: 0, y: 0))
    }

    func testCanPlaceRejectsOverlaps() {
        var board = Board()
        board.cells[19][0] = Cell(filled: true, kind: .i)
        let piece = Tetromino(kind: .i, x: 0, y: 18)
        XCTAssertFalse(board.canPlace(piece: piece, x: 0, y: 18, rotation: .north))
    }

    func testLockPieceMarksCells() {
        var board = Board()
        let piece = Tetromino(kind: .o, x: 0, y: 0)
        board.lock(piece: piece)
        XCTAssertTrue(board.cells[0][1].filled)
        XCTAssertTrue(board.cells[0][2].filled)
        XCTAssertTrue(board.cells[1][1].filled)
        XCTAssertTrue(board.cells[1][2].filled)
    }

    func testClearLinesCollapsesRows() {
        var board = Board()
        for x in 0..<Board.width {
            board.cells[19][x] = Cell(filled: true, kind: .i)
        }
        board.cells[18][0] = Cell(filled: true, kind: .o)
        let result = board.clearLines()
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(board.cells[19][0].filled)
        XCTAssertFalse(board.cells[18][0].filled)
    }

    func testClearLinesReturnsClearedRowIndices() {
        var board = Board()
        for x in 0..<Board.width {
            board.cells[19][x] = Cell(filled: true, kind: .i)
            board.cells[17][x] = Cell(filled: true, kind: .t)
        }
        let result = board.clearLines()
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.rows, [19, 17])
    }
}
