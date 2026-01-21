public struct Cell: Equatable {
    public var filled: Bool
    public var kind: TetrominoType?

    public init(filled: Bool = false, kind: TetrominoType? = nil) {
        self.filled = filled
        self.kind = kind
    }
}

public struct Board: Equatable {
    public static let width = 10
    public static let height = 20

    public var cells: [[Cell]]

    public init() {
        let row = Array(repeating: Cell(), count: Board.width)
        self.cells = Array(repeating: row, count: Board.height)
    }

    public func isInside(x: Int, y: Int) -> Bool {
        x >= 0 && x < Board.width && y >= 0 && y < Board.height
    }

    public func isOccupied(x: Int, y: Int) -> Bool {
        guard isInside(x: x, y: y) else { return true }
        return cells[y][x].filled
    }

    public func canPlace(piece: Tetromino, x: Int, y: Int, rotation: Rotation) -> Bool {
        for (dx, dy) in piece.blocks(rotation: rotation) {
            let nx = x + dx
            let ny = y + dy
            if isOccupied(x: nx, y: ny) {
                return false
            }
        }
        return true
    }

    public mutating func lock(piece: Tetromino) {
        for (dx, dy) in piece.blocks(rotation: piece.rotation) {
            let nx = piece.x + dx
            let ny = piece.y + dy
            guard isInside(x: nx, y: ny) else { continue }
            cells[ny][nx].filled = true
            cells[ny][nx].kind = piece.kind
        }
    }

    public mutating func clearLines() -> Int {
        var cleared = 0
        var writeRow = Board.height - 1

        for readRow in stride(from: Board.height - 1, through: 0, by: -1) {
            let full = cells[readRow].allSatisfy { $0.filled }
            if full {
                cleared += 1
            } else {
                if writeRow != readRow {
                    cells[writeRow] = cells[readRow]
                }
                writeRow -= 1
            }
        }

        if writeRow >= 0 {
            for y in 0...writeRow {
                cells[y] = Array(repeating: Cell(), count: Board.width)
            }
        }

        return cleared
    }
}
