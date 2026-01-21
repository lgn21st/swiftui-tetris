public struct PreviewMaskCache {
    private var masks: [TetrominoType: [[Bool]]]
    private static let size = 4

    public init() {
        self.masks = [:]
    }

    public func mask(for kind: TetrominoType?) -> [[Bool]] {
        guard let kind else {
            return Array(repeating: Array(repeating: false, count: Self.size), count: Self.size)
        }
        if let cached = masks[kind] {
            return cached
        }
        var filled = Array(repeating: Array(repeating: false, count: Self.size), count: Self.size)
        let piece = Tetromino(kind: kind, x: 0, y: 0)
        for (dx, dy) in piece.blocks(rotation: piece.rotation) {
            if dx >= 0 && dx < Self.size && dy >= 0 && dy < Self.size {
                filled[dy][dx] = true
            }
        }
        return filled
    }
}
