import XCTest
import CoreGraphics
@testable import Renderer
@testable import Core

final class BoardGridTests: XCTestCase {
    func testGridSegmentsIncludeAllBoardLines() {
        let cellSize: CGFloat = 10
        let segments = BoardGrid.segments(cellSize: cellSize)

        let verticalCount = Board.width + 1
        let horizontalCount = Board.height + 1
        XCTAssertEqual(segments.count, verticalCount + horizontalCount)
    }

    func testGridSegmentsStartAndEndAtBoardBounds() {
        let cellSize: CGFloat = 8
        let segments = BoardGrid.segments(cellSize: cellSize)
        let width = CGFloat(Board.width) * cellSize
        let height = CGFloat(Board.height) * cellSize

        let verticals = segments.filter { $0.start.x == $0.end.x }
        let horizontals = segments.filter { $0.start.y == $0.end.y }

        XCTAssertEqual(verticals.first?.start.x, 0)
        XCTAssertEqual(verticals.first?.start.y, 0)
        XCTAssertEqual(verticals.first?.end.y, height)
        XCTAssertEqual(verticals.last?.start.x, width)
        XCTAssertEqual(verticals.last?.end.y, height)

        XCTAssertEqual(horizontals.first?.start.y, 0)
        XCTAssertEqual(horizontals.first?.start.x, 0)
        XCTAssertEqual(horizontals.first?.end.x, width)
        XCTAssertEqual(horizontals.last?.start.y, height)
        XCTAssertEqual(horizontals.last?.end.x, width)
    }
}
