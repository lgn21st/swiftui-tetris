import Core

public struct PreviewGridState: Equatable {
    public var kind: TetrominoType?
    public var mask: [[Bool]]

    public static func from(kind: TetrominoType?) -> PreviewGridState {
        let cache = PreviewMaskCache()
        return PreviewGridState(kind: kind, mask: cache.mask(for: kind))
    }

    public func filledCount() -> Int {
        mask.reduce(0) { total, row in
            total + row.filter { $0 }.count
        }
    }
}
