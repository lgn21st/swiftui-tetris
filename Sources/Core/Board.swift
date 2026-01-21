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
}
