import XCTest
@testable import Core

final class SrsKickTests: XCTestCase {
    func testSrsKickTableForI0ToR() {
        let kicks = srsKicks(kind: .i, from: .north, to: .east)
        XCTAssertEqual(kicks.count, 5)
        XCTAssertEqual(kicks[0].0, 0)
        XCTAssertEqual(kicks[0].1, 0)
        XCTAssertEqual(kicks[1].0, -2)
        XCTAssertEqual(kicks[1].1, 0)
    }

    func testRotateUsesKickWhenBlocked() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 0, y: 0)
        state.board.cells[1][0] = Cell(filled: true, kind: .z)
        let rotated = state.rotate(clockwise: false)
        XCTAssertTrue(rotated)
        XCTAssertEqual(state.active.rotation, .west)
        XCTAssertEqual(state.active.x, 1)
    }
}
