import Testing
@testable import Core

@Suite struct BoardTests {
    @Test func testBoardDimensions() {
        #expect(Board.width == 10)
        #expect(Board.height == 20)
    }

    @Test func testBoardStartsEmpty() {
        let board = Board()
        let filled = board.cells.flatMap { $0 }.filter { $0.filled }
        #expect(filled.isEmpty)
    }
}
