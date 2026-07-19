import Testing
import Foundation
import CoreGraphics
@testable import Renderer
@testable import Core

@Suite struct BoardGridTests {
    @Test func testGridSegmentsIncludeAllBoardLines() {
        let cellSize: CGFloat = 10
        let segments = BoardGrid.segments(cellSize: cellSize)

        let verticalCount = Board.width + 1
        let horizontalCount = Board.height + 1
        #expect(segments.count == verticalCount + horizontalCount)
    }

    @Test func testGridSegmentsStartAndEndAtBoardBounds() {
        let cellSize: CGFloat = 8
        let segments = BoardGrid.segments(cellSize: cellSize)
        let width = CGFloat(Board.width) * cellSize
        let height = CGFloat(Board.height) * cellSize

        let verticals = segments.filter { $0.start.x == $0.end.x }
        let horizontals = segments.filter { $0.start.y == $0.end.y }

        #expect(verticals.first?.start.x == 0)
        #expect(verticals.first?.start.y == 0)
        #expect(verticals.first?.end.y == height)
        #expect(verticals.last?.start.x == width)
        #expect(verticals.last?.end.y == height)

        #expect(horizontals.first?.start.y == 0)
        #expect(horizontals.first?.start.x == 0)
        #expect(horizontals.first?.end.x == width)
        #expect(horizontals.last?.start.y == height)
        #expect(horizontals.last?.end.x == width)
    }
}
