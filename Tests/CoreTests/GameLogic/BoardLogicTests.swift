import Testing
@testable import Core

@Suite struct BoardLogicTests {
    @Test func testIsInsideBounds() {
        let board = Board()
        #expect(board.isInside(x: 0, y: 0))
        #expect(board.isInside(x: 9, y: 19))
        #expect(!board.isInside(x: -1, y: 0))
        #expect(!board.isInside(x: 10, y: 0))
        #expect(!board.isInside(x: 0, y: -1))
        #expect(!board.isInside(x: 0, y: 20))
    }

    @Test func testIsOccupiedTreatsOutOfBoundsAsFilled() {
        let board = Board()
        #expect(board.isOccupied(x: -1, y: 0))
        #expect(board.isOccupied(x: 10, y: 0))
        #expect(board.isOccupied(x: 0, y: -1))
        #expect(board.isOccupied(x: 0, y: 20))
        #expect(!board.isOccupied(x: 0, y: 0))
    }

    @Test func testCanPlaceRejectsOverlaps() {
        var board = Board()
        board.cells[19][0] = Cell(filled: true, kind: .i)
        let piece = Tetromino(kind: .i, x: 0, y: 18)
        #expect(!board.canPlace(piece: piece, x: 0, y: 18, rotation: .north))
    }

    @Test func testLockPieceMarksCells() {
        var board = Board()
        let piece = Tetromino(kind: .o, x: 0, y: 0)
        board.lock(piece: piece)
        #expect(board.cells[0][1].filled)
        #expect(board.cells[0][2].filled)
        #expect(board.cells[1][1].filled)
        #expect(board.cells[1][2].filled)
    }

    @Test func testClearLinesCollapsesRows() {
        var board = Board()
        for x in 0..<Board.width {
            board.cells[19][x] = Cell(filled: true, kind: .i)
        }
        board.cells[18][0] = Cell(filled: true, kind: .o)
        let result = board.clearLines()
        #expect(result.count == 1)
        #expect(board.cells[19][0].filled)
        #expect(!board.cells[18][0].filled)
    }

    @Test func testClearLinesReturnsClearedRowIndices() {
        var board = Board()
        for x in 0..<Board.width {
            board.cells[19][x] = Cell(filled: true, kind: .i)
            board.cells[17][x] = Cell(filled: true, kind: .t)
        }
        let result = board.clearLines()
        #expect(result.count == 2)
        #expect(result.rows == [19, 17])
    }
}
