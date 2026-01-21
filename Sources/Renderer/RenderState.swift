import Core

public struct RenderState {
    public var board: [[TetrominoType?]]
    public var activeBlocks: [(Int, Int)]
    public var ghostBlocks: [(Int, Int)]
    public var activeKind: TetrominoType?
    public var ghostKind: TetrominoType?
    public var flashBlocks: [(Int, Int)]
    public var flashAlpha: Double

    public init(
        board: [[TetrominoType?]],
        activeBlocks: [(Int, Int)],
        ghostBlocks: [(Int, Int)],
        activeKind: TetrominoType?,
        ghostKind: TetrominoType?,
        flashBlocks: [(Int, Int)],
        flashAlpha: Double
    ) {
        self.board = board
        self.activeBlocks = activeBlocks
        self.ghostBlocks = ghostBlocks
        self.activeKind = activeKind
        self.ghostKind = ghostKind
        self.flashBlocks = flashBlocks
        self.flashAlpha = flashAlpha
    }
}

public enum RenderMapper {
    public static func map(state: GameState) -> RenderState {
        let board = state.board.cells.map { row in
            row.map { $0.filled ? $0.kind : nil }
        }
        let hideActive = state.lineClearTimerMs > 0
        let activeBlocks = hideActive ? [] : state.active.blocks(rotation: state.active.rotation).map { (dx, dy) in
            (state.active.x + dx, state.active.y + dy)
        }
        let ghostBlocks = hideActive ? [] : state.ghostBlocks()
        let flashBlocks = state.landingFlashTimerMs > 0 ? state.landingFlashBlocks : []
        let flashAlpha = state.landingFlashTimerMs > 0
        ? min(max(Double(state.landingFlashTimerMs) / Double(GameState.landingFlashDurationMs), 0), 1)
        : 0
        return RenderState(
            board: board,
            activeBlocks: activeBlocks,
            ghostBlocks: ghostBlocks,
            activeKind: hideActive ? nil : state.active.kind,
            ghostKind: hideActive ? nil : state.active.kind,
            flashBlocks: flashBlocks,
            flashAlpha: flashAlpha
        )
    }
}
