public func srsKicks(kind: TetrominoType, from: Rotation, to: Rotation) -> [(Int, Int)] {
    if kind == .o {
        return Array(repeating: (0, 0), count: 5)
    }

    if kind == .i {
        switch (from, to) {
        case (.north, .east): return [(0, 0), (-2, 0), (1, 0), (-2, -1), (1, 2)]
        case (.east, .north): return [(0, 0), (2, 0), (-1, 0), (2, 1), (-1, -2)]
        case (.east, .south): return [(0, 0), (-1, 0), (2, 0), (-1, 2), (2, -1)]
        case (.south, .east): return [(0, 0), (1, 0), (-2, 0), (1, -2), (-2, 1)]
        case (.south, .west): return [(0, 0), (2, 0), (-1, 0), (2, 1), (-1, -2)]
        case (.west, .south): return [(0, 0), (-2, 0), (1, 0), (-2, -1), (1, 2)]
        case (.west, .north): return [(0, 0), (1, 0), (-2, 0), (1, -2), (-2, 1)]
        case (.north, .west): return [(0, 0), (-1, 0), (2, 0), (-1, 2), (2, -1)]
        default: return [(0, 0), (-2, 0), (1, 0), (-2, -1), (1, 2)]
        }
    }

    switch (from, to) {
    case (.north, .east): return [(0, 0), (-1, 0), (-1, 1), (0, -2), (-1, -2)]
    case (.east, .north): return [(0, 0), (1, 0), (1, -1), (0, 2), (1, 2)]
    case (.east, .south): return [(0, 0), (1, 0), (1, -1), (0, 2), (1, 2)]
    case (.south, .east): return [(0, 0), (-1, 0), (-1, 1), (0, -2), (-1, -2)]
    case (.south, .west): return [(0, 0), (1, 0), (1, 1), (0, -2), (1, -2)]
    case (.west, .south): return [(0, 0), (-1, 0), (-1, -1), (0, 2), (-1, 2)]
    case (.west, .north): return [(0, 0), (-1, 0), (-1, -1), (0, 2), (-1, 2)]
    case (.north, .west): return [(0, 0), (1, 0), (1, 1), (0, -2), (1, -2)]
    default: return [(0, 0), (-1, 0), (-1, 1), (0, -2), (-1, -2)]
    }
}
