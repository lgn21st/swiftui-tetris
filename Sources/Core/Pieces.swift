public enum TetrominoType: Int, CaseIterable {
    case i, o, t, s, z, j, l
}

public enum Rotation: Int, CaseIterable {
    case north, east, south, west

    public func cw() -> Rotation {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        }
    }

    public func ccw() -> Rotation {
        switch self {
        case .north: return .west
        case .west: return .south
        case .south: return .east
        case .east: return .north
        }
    }
}

public struct Tetromino: Equatable {
    public var kind: TetrominoType
    public var rotation: Rotation
    public var x: Int
    public var y: Int

    public init(kind: TetrominoType, x: Int, y: Int) {
        self.kind = kind
        self.rotation = .north
        self.x = x
        self.y = y
    }

    public func blocks(rotation: Rotation) -> [(Int, Int)] {
        shapeFor(kind: kind, rotation: rotation)
    }
}

public func spawnPosition() -> (x: Int, y: Int) {
    (3, 0)
}

private func shapeFor(kind: TetrominoType, rotation: Rotation) -> [(Int, Int)] {
    tetrominoShapes[kind.rawValue][rotation.rawValue]
}

// Construct the immutable shape table once. `blocks(rotation:)` is used by
// collision checks, ghost mapping, rendering, and path planning, so rebuilding
// this nested array on every query creates avoidable hot-path allocations.
private let tetrominoShapes: [[[(Int, Int)]]] = [
        // I
        [
            [(0, 1), (1, 1), (2, 1), (3, 1)],
            [(2, 0), (2, 1), (2, 2), (2, 3)],
            [(0, 2), (1, 2), (2, 2), (3, 2)],
            [(1, 0), (1, 1), (1, 2), (1, 3)]
        ],
        // O
        [
            [(1, 0), (2, 0), (1, 1), (2, 1)],
            [(1, 0), (2, 0), (1, 1), (2, 1)],
            [(1, 0), (2, 0), (1, 1), (2, 1)],
            [(1, 0), (2, 0), (1, 1), (2, 1)]
        ],
        // T
        [
            [(1, 0), (0, 1), (1, 1), (2, 1)],
            [(1, 0), (1, 1), (2, 1), (1, 2)],
            [(0, 1), (1, 1), (2, 1), (1, 2)],
            [(1, 0), (0, 1), (1, 1), (1, 2)]
        ],
        // S
        [
            [(1, 0), (2, 0), (0, 1), (1, 1)],
            [(1, 0), (1, 1), (2, 1), (2, 2)],
            [(1, 1), (2, 1), (0, 2), (1, 2)],
            [(0, 0), (0, 1), (1, 1), (1, 2)]
        ],
        // Z
        [
            [(0, 0), (1, 0), (1, 1), (2, 1)],
            [(2, 0), (1, 1), (2, 1), (1, 2)],
            [(0, 1), (1, 1), (1, 2), (2, 2)],
            [(1, 0), (0, 1), (1, 1), (0, 2)]
        ],
        // J
        [
            [(0, 0), (0, 1), (1, 1), (2, 1)],
            [(1, 0), (2, 0), (1, 1), (1, 2)],
            [(0, 1), (1, 1), (2, 1), (2, 2)],
            [(1, 0), (1, 1), (0, 2), (1, 2)]
        ],
        // L
        [
            [(2, 0), (0, 1), (1, 1), (2, 1)],
            [(1, 0), (1, 1), (1, 2), (2, 2)],
            [(0, 1), (1, 1), (2, 1), (0, 2)],
            [(0, 0), (1, 0), (1, 1), (1, 2)]
        ]
]
