import XCTest
@testable import Core

final class TSpinTests: XCTestCase {
    func testTSpinFullDetectedWhenFrontCornersFilled() {
        var state = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.lastActionRotate = true
        // Fill 3 corners, including both front corners for North rotation.
        state.board.cells[0][3] = Cell(filled: true, kind: .i)
        state.board.cells[0][5] = Cell(filled: true, kind: .i)
        state.board.cells[2][3] = Cell(filled: true, kind: .i)
        XCTAssertEqual(state.tSpinKind(), .full)
    }

    func testTSpinMiniDetectedWhenThreeCornersButOneFrontEmpty() {
        var state = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.lastActionRotate = true
        // Fill three corners, but only one front corner for North rotation.
        state.board.cells[0][3] = Cell(filled: true, kind: .i)
        state.board.cells[2][3] = Cell(filled: true, kind: .i)
        state.board.cells[2][5] = Cell(filled: true, kind: .i)
        XCTAssertEqual(state.tSpinKind(), .mini)
    }

    func testTSpinRequiresRotationAction() {
        var state = GameState(config: GameConfig(ruleset: .modern), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.lastActionRotate = false
        state.board.cells[0][3] = Cell(filled: true, kind: .i)
        state.board.cells[0][5] = Cell(filled: true, kind: .i)
        state.board.cells[2][3] = Cell(filled: true, kind: .i)
        XCTAssertEqual(state.tSpinKind(), .none)
    }
}
