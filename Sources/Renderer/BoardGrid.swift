import CoreGraphics
import Core

public struct LineSegment: Equatable {
    public let start: CGPoint
    public let end: CGPoint

    public init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
}

public enum BoardGrid {
    public static func segments(cellSize: CGFloat) -> [LineSegment] {
        let width = CGFloat(Board.width) * cellSize
        let height = CGFloat(Board.height) * cellSize
        var segments: [LineSegment] = []
        segments.reserveCapacity((Board.width + 1) + (Board.height + 1))

        for x in 0...Board.width {
            let xPos = CGFloat(x) * cellSize
            segments.append(LineSegment(
                start: CGPoint(x: xPos, y: 0),
                end: CGPoint(x: xPos, y: height)
            ))
        }

        for y in 0...Board.height {
            let yPos = CGFloat(y) * cellSize
            segments.append(LineSegment(
                start: CGPoint(x: 0, y: yPos),
                end: CGPoint(x: width, y: yPos)
            ))
        }

        return segments
    }

    public static func path(cellSize: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for segment in segments(cellSize: cellSize) {
            path.move(to: segment.start)
            path.addLine(to: segment.end)
        }
        return path
    }
}
