import XCTest
@testable import Core

final class BoardTests: XCTestCase {
    func testBoardDimensions() {
        XCTAssertEqual(Board.width, 10)
        XCTAssertEqual(Board.height, 20)
    }

    func testBoardStartsEmpty() {
        let board = Board()
        let filled = board.cells.flatMap { $0 }.filter { $0.filled }
        XCTAssertTrue(filled.isEmpty)
    }
}
