import Core

public struct RenderState {
    public var board: [[TetrominoType?]]
    public var activeBlocks: [(Int, Int)]
    public var ghostBlocks: [(Int, Int)]

    public init(board: [[TetrominoType?]], activeBlocks: [(Int, Int)], ghostBlocks: [(Int, Int)]) {
        self.board = board
        self.activeBlocks = activeBlocks
        self.ghostBlocks = ghostBlocks
    }
}

public enum RenderMapper {
    public static func map(state: GameState) -> RenderState {
        let board = state.board.cells.map { row in
            row.map { $0.filled ? $0.kind : nil }
        }
        let activeBlocks = state.active.blocks(rotation: state.active.rotation).map { (dx, dy) in
            (state.active.x + dx, state.active.y + dy)
        }
        let ghostBlocks = state.ghostBlocks()
        return RenderState(board: board, activeBlocks: activeBlocks, ghostBlocks: ghostBlocks)
    }
}
