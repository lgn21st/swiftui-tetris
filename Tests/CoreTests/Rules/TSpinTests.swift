import Testing
@testable import Core

@Suite struct TSpinTests {
    @Test func testTSpinFullDetectedWhenFrontCornersFilled() {
        var state = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.lastActionRotate = true
        // Fill 3 corners, including both front corners for North rotation.
        state.board.cells[0][3] = Cell(filled: true, kind: .i)
        state.board.cells[0][5] = Cell(filled: true, kind: .i)
        state.board.cells[2][3] = Cell(filled: true, kind: .i)
        #expect(state.tSpinKind() == .full)
    }

    @Test func testTSpinMiniDetectedWhenThreeCornersButOneFrontEmpty() {
        var state = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.lastActionRotate = true
        // Fill three corners, but only one front corner for North rotation.
        state.board.cells[0][3] = Cell(filled: true, kind: .i)
        state.board.cells[2][3] = Cell(filled: true, kind: .i)
        state.board.cells[2][5] = Cell(filled: true, kind: .i)
        #expect(state.tSpinKind() == .mini)
    }

    @Test func testTSpinRequiresRotationAction() {
        var state = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.lastActionRotate = false
        state.board.cells[0][3] = Cell(filled: true, kind: .i)
        state.board.cells[0][5] = Cell(filled: true, kind: .i)
        state.board.cells[2][3] = Cell(filled: true, kind: .i)
        #expect(state.tSpinKind() == .none)
    }

    @Test func testLockDetectsTSpinBeforeClearedRowsShiftBoard() {
        var state = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 17)
        state.lastActionRotate = true

        for x in 0..<Board.width where !(3...5).contains(x) {
            state.board.cells[18][x] = Cell(filled: true, kind: .i)
        }
        state.board.cells[17][3] = Cell(filled: true, kind: .i)
        state.board.cells[17][5] = Cell(filled: true, kind: .i)
        state.board.cells[19][3] = Cell(filled: true, kind: .i)

        #expect(state.hardDrop() == 0)

        #expect(state.lines == 1)
        #expect(state.lastLineClearTSpin == .full)
        #expect(state.lineClearScore == 800)
        #expect(state.score == 800)
    }
}
