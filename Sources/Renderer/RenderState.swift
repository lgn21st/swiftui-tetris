import Core

public struct RenderState {
    public var board: [[TetrominoType?]]
    public var activeBlocks: [(Int, Int)]
    public var ghostBlocks: [(Int, Int)]
    public var activeKind: TetrominoType?
    public var ghostKind: TetrominoType?
    public var softDropTrailBlocks: [(Int, Int)]
    public var softDropTrailKind: TetrominoType?
    public var flashBlocks: [(Int, Int)]
    public var flashAlpha: Double
    public var isPaused: Bool
    public var isGameOver: Bool

    public init(
        board: [[TetrominoType?]],
        activeBlocks: [(Int, Int)],
        ghostBlocks: [(Int, Int)],
        activeKind: TetrominoType?,
        ghostKind: TetrominoType?,
        softDropTrailBlocks: [(Int, Int)],
        softDropTrailKind: TetrominoType?,
        flashBlocks: [(Int, Int)],
        flashAlpha: Double,
        isPaused: Bool,
        isGameOver: Bool
    ) {
        self.board = board
        self.activeBlocks = activeBlocks
        self.ghostBlocks = ghostBlocks
        self.activeKind = activeKind
        self.ghostKind = ghostKind
        self.softDropTrailBlocks = softDropTrailBlocks
        self.softDropTrailKind = softDropTrailKind
        self.flashBlocks = flashBlocks
        self.flashAlpha = flashAlpha
        self.isPaused = isPaused
        self.isGameOver = isGameOver
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
        let trailBlocks = hideActive ? [] : softDropTrailBlocks(
            activeBlocks: activeBlocks,
            ghostBlocks: ghostBlocks,
            isSoftDropActive: state.softDropActive
        )
        return RenderState(
            board: board,
            activeBlocks: activeBlocks,
            ghostBlocks: ghostBlocks,
            activeKind: hideActive ? nil : state.active.kind,
            ghostKind: hideActive ? nil : state.active.kind,
            softDropTrailBlocks: trailBlocks,
            softDropTrailKind: trailBlocks.isEmpty ? nil : state.active.kind,
            flashBlocks: flashBlocks,
            flashAlpha: flashAlpha,
            isPaused: state.paused,
            isGameOver: state.gameOver
        )
    }

    private static func softDropTrailBlocks(
        activeBlocks: [(Int, Int)],
        ghostBlocks: [(Int, Int)],
        isSoftDropActive: Bool
    ) -> [(Int, Int)] {
        guard isSoftDropActive, !activeBlocks.isEmpty, activeBlocks.count == ghostBlocks.count else {
            return []
        }
        let dx = ghostBlocks[0].0 - activeBlocks[0].0
        let dy = ghostBlocks[0].1 - activeBlocks[0].1
        guard dy > 1, dx == 0 else { return [] }
        struct GridPoint: Hashable {
            let x: Int
            let y: Int
        }
        var unique: Set<GridPoint> = []
        unique.reserveCapacity(activeBlocks.count * dy)
        for (ax, ay) in activeBlocks {
            for step in 1..<dy {
                unique.insert(GridPoint(x: ax, y: ay + step))
            }
        }
        return unique
            .map { ($0.x, $0.y) }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 { return lhs.0 < rhs.0 }
                return lhs.1 < rhs.1
            }
    }
}
