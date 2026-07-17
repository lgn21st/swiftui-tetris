import Core

public struct RenderState {
    public var boardCells: [[Cell]]
    // Compatibility view for callers that still consume projected kinds.
    // The renderer itself uses `boardCells` so this projection is not on the
    // per-frame path.
    public var board: [[TetrominoType?]] {
        get {
            boardCells.map { row in
                row.map { $0.filled ? $0.kind : nil }
            }
        }
        set {
            boardCells = newValue.map { row in
                row.map { kind in Cell(filled: kind != nil, kind: kind) }
            }
        }
    }
    public var activeBlocks: [(Int, Int)]
    public var ghostBlocks: [(Int, Int)]
    public var activeKind: TetrominoType?
    public var ghostKind: TetrominoType?
    public var flashBlocks: [(Int, Int)]
    public var flashAlpha: Double
    public var lineClearRows: [Int]
    public var lineClearAlpha: Double
    public var scorePopups: [ScorePopup]
    public var tSpinKind: TSpinKind
    public var tSpinAlpha: Double
    public var activePulse: Double
    public var isGrounded: Bool
    public var isPaused: Bool
    public var isGameOver: Bool

    public init(
        board: [[TetrominoType?]],
        activeBlocks: [(Int, Int)],
        ghostBlocks: [(Int, Int)],
        activeKind: TetrominoType?,
        ghostKind: TetrominoType?,
        flashBlocks: [(Int, Int)],
        flashAlpha: Double,
        lineClearRows: [Int],
        lineClearAlpha: Double,
        scorePopups: [ScorePopup],
        tSpinKind: TSpinKind,
        tSpinAlpha: Double,
        activePulse: Double,
        isGrounded: Bool,
        isPaused: Bool,
        isGameOver: Bool
    ) {
        self.boardCells = board.map { row in
            row.map { kind in Cell(filled: kind != nil, kind: kind) }
        }
        self.activeBlocks = activeBlocks
        self.ghostBlocks = ghostBlocks
        self.activeKind = activeKind
        self.ghostKind = ghostKind
        self.flashBlocks = flashBlocks
        self.flashAlpha = flashAlpha
        self.lineClearRows = lineClearRows
        self.lineClearAlpha = lineClearAlpha
        self.scorePopups = scorePopups
        self.tSpinKind = tSpinKind
        self.tSpinAlpha = tSpinAlpha
        self.activePulse = activePulse
        self.isGrounded = isGrounded
        self.isPaused = isPaused
        self.isGameOver = isGameOver
    }

    init(
        boardCells: [[Cell]],
        activeBlocks: [(Int, Int)],
        ghostBlocks: [(Int, Int)],
        activeKind: TetrominoType?,
        ghostKind: TetrominoType?,
        flashBlocks: [(Int, Int)],
        flashAlpha: Double,
        lineClearRows: [Int],
        lineClearAlpha: Double,
        scorePopups: [ScorePopup],
        tSpinKind: TSpinKind,
        tSpinAlpha: Double,
        activePulse: Double,
        isGrounded: Bool,
        isPaused: Bool,
        isGameOver: Bool
    ) {
        self.boardCells = boardCells
        self.activeBlocks = activeBlocks
        self.ghostBlocks = ghostBlocks
        self.activeKind = activeKind
        self.ghostKind = ghostKind
        self.flashBlocks = flashBlocks
        self.flashAlpha = flashAlpha
        self.lineClearRows = lineClearRows
        self.lineClearAlpha = lineClearAlpha
        self.scorePopups = scorePopups
        self.tSpinKind = tSpinKind
        self.tSpinAlpha = tSpinAlpha
        self.activePulse = activePulse
        self.isGrounded = isGrounded
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
    public static func map(snapshot: GameStateSnapshot) -> RenderState {
        let isGrounded = !snapshot.canMoveDown()
        let hideActive = snapshot.lineClearTimerMs > 0
        let activeBlocks = hideActive
        ? []
        : snapshot.active.blocks(rotation: snapshot.active.rotation).map { (dx, dy) in
            (snapshot.active.x + dx, snapshot.active.y + dy)
        }
        let hideGhost = snapshot.lineClearTimerMs > 0
            || snapshot.lockTimerMs > 0
            || isGrounded
            || !snapshot.activeMovedSinceSpawn
        let ghostBlocks = hideGhost ? [] : snapshot.ghostBlocks
        let flashBlocks = snapshot.landingFlashTimerMs > 0 ? snapshot.landingFlashBlocks : []
        let flashAlpha = snapshot.landingFlashTimerMs > 0
        ? min(max(Double(snapshot.landingFlashTimerMs) / Double(GameConstants.landingFlashDurationMs), 0), 1)
        : 0
        let suppressPulse = snapshot.lineClearTimerMs > 0
        let activePulse = suppressPulse ? 0 : activePulseValue(
            dropTimerMs: snapshot.dropTimerMs,
            intervalMs: Timing.dropInterval(
                level: snapshot.level,
                baseDropMs: snapshot.config.baseDropMs,
                softDrop: snapshot.softDropActive,
                softDropMultiplier: snapshot.config.softDropMultiplier
            )
        )
        let lineClearAlpha = snapshot.lineClearTimerMs > 0
        ? min(max(Double(snapshot.lineClearTimerMs) / Double(GameConstants.lineClearPauseMs), 0), 1)
        : 0
        let lineClearRows = snapshot.lineClearTimerMs > 0 ? snapshot.lineClearRows : []
        let tSpinKind = snapshot.lineClearTimerMs > 0 ? snapshot.lastLineClearTSpin : .none
        let tSpinAlpha = tSpinKind == .none ? 0 : lineClearAlpha
        let scorePopups = mapScorePopups(
            lineClearRows: lineClearRows,
            lineClearAlpha: lineClearAlpha,
            lineClearScore: snapshot.lineClearScore
        )
        return RenderState(
            boardCells: snapshot.boardCells,
            activeBlocks: activeBlocks,
            ghostBlocks: ghostBlocks,
            activeKind: hideActive ? nil : snapshot.active.kind,
            ghostKind: hideGhost ? nil : snapshot.active.kind,
            flashBlocks: flashBlocks,
            flashAlpha: flashAlpha,
            lineClearRows: lineClearRows,
            lineClearAlpha: lineClearAlpha,
            scorePopups: scorePopups,
            tSpinKind: tSpinKind,
            tSpinAlpha: tSpinAlpha,
            activePulse: activePulse,
            isGrounded: isGrounded,
            isPaused: snapshot.paused,
            isGameOver: snapshot.gameOver
        )
    }

    private static func activePulseValue(dropTimerMs: Int, intervalMs: Int) -> Double {
        guard intervalMs > 0 else { return 0 }
        let remainder = max(dropTimerMs, 0) % intervalMs
        let progress = Double(remainder) / Double(intervalMs)
        let triangle = progress < 0.5 ? progress * 2 : (1 - progress) * 2
        return min(max(triangle, 0), 1)
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
