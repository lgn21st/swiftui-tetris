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
    public var lineClearRows: [Int]
    public var lineClearAlpha: Double
    public var scorePopups: [ScorePopup]
    public var activePulse: Double
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
        lineClearRows: [Int],
        lineClearAlpha: Double,
        scorePopups: [ScorePopup],
        activePulse: Double,
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
        self.lineClearRows = lineClearRows
        self.lineClearAlpha = lineClearAlpha
        self.scorePopups = scorePopups
        self.activePulse = activePulse
        self.isPaused = isPaused
        self.isGameOver = isGameOver
    }
}

public struct ScorePopup: Equatable {
    public var text: String
    public var x: Double
    public var y: Double
    public var alpha: Double

    public init(text: String, x: Double, y: Double, alpha: Double) {
        self.text = text
        self.x = x
        self.y = y
        self.alpha = alpha
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
        let activePulse = hideActive ? 0 : activePulseValue(
            dropTimerMs: state.dropTimerMs,
            intervalMs: Timing.dropInterval(
                level: state.level,
                baseDropMs: state.config.baseDropMs,
                softDrop: state.softDropActive,
                softDropMultiplier: state.config.softDropMultiplier
            )
        )
        let lineClearAlpha = state.lineClearTimerMs > 0
        ? min(max(Double(state.lineClearTimerMs) / Double(GameState.lineClearPauseMs), 0), 1)
        : 0
        let lineClearRows = state.lineClearTimerMs > 0 ? state.lineClearRows : []
        let scorePopups = mapScorePopups(
            lineClearRows: lineClearRows,
            lineClearAlpha: lineClearAlpha,
            lineClearScore: state.lineClearScore
        )
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
            lineClearRows: lineClearRows,
            lineClearAlpha: lineClearAlpha,
            scorePopups: scorePopups,
            activePulse: activePulse,
            isPaused: state.paused,
            isGameOver: state.gameOver
        )
    }

    private static func activePulseValue(dropTimerMs: Int, intervalMs: Int) -> Double {
        guard intervalMs > 0 else { return 0 }
        let remainder = max(dropTimerMs, 0) % intervalMs
        let progress = Double(remainder) / Double(intervalMs)
        let triangle = progress < 0.5 ? progress * 2 : (1 - progress) * 2
        return min(max(triangle, 0), 1)
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

    private static func mapScorePopups(
        lineClearRows: [Int],
        lineClearAlpha: Double,
        lineClearScore: Int
    ) -> [ScorePopup] {
        guard lineClearScore > 0, !lineClearRows.isEmpty else { return [] }
        let avgRow = Double(lineClearRows.reduce(0, +)) / Double(lineClearRows.count)
        let centerX = Double(Board.width - 1) / 2.0
        return [
            ScorePopup(
                text: "+\(lineClearScore)",
                x: centerX,
                y: avgRow,
                alpha: lineClearAlpha
            )
        ]
    }
}
