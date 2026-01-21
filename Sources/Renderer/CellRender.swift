import Core

public struct CellRender: Equatable {
    public var x: Int
    public var y: Int
    public var kind: TetrominoType?
    public var isGhost: Bool
    public var isActive: Bool
    public var isFlash: Bool
    public var isLineClear: Bool
}
