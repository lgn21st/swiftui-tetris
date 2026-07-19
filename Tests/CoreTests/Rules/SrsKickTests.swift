import Testing
@testable import Core

@Suite struct SrsKickTests {
    @Test func testSrsKickTableForI0ToR() {
        let kicks = srsKicks(kind: .i, from: .north, to: .east)
        #expect(kicks.count == 5)
        #expect(kicks[0].0 == 0)
        #expect(kicks[0].1 == 0)
        #expect(kicks[1].0 == -2)
        #expect(kicks[1].1 == 0)
    }

    @Test func testRotateUsesKickWhenBlocked() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .t, x: 0, y: 0)
        state.board.cells[1][0] = Cell(filled: true, kind: .z)
        let rotated = state.rotate(clockwise: false)
        #expect(rotated)
        #expect(state.active.rotation == .west)
        #expect(state.active.x == 1)
    }
}
