public struct GameStateSnapshot {
    public let boardCells: [[Cell]]
    public let active: Tetromino
    public let paused: Bool
    public let gameOver: Bool
    public let score: Int
    public let level: Int
    public let lines: Int
    public let hold: TetrominoType?
    public let canHold: Bool
    public let nextQueue: [TetrominoType]
    public let dropTimerMs: Int
    public let lockTimerMs: Int
    public let lineClearTimerMs: Int
    public let lineClearRows: [Int]
    public let lineClearScore: Int
    public let lastLineClearTSpin: TSpinKind
    public let landingFlashTimerMs: Int
    public let landingFlashBlocks: [(Int, Int)]
    public let softDropActive: Bool
    public let softDropTimeoutMs: Int
    public let lockResetCount: Int
    public let activeMovedSinceSpawn: Bool
    public let ghostBlocks: [(Int, Int)]
    public let config: GameConfig

    public init(
        boardCells: [[Cell]],
        active: Tetromino,
        paused: Bool,
        gameOver: Bool,
        score: Int,
        level: Int,
        lines: Int,
        hold: TetrominoType?,
        canHold: Bool,
        nextQueue: [TetrominoType],
        dropTimerMs: Int,
        lockTimerMs: Int,
        lineClearTimerMs: Int,
        lineClearRows: [Int],
        lineClearScore: Int,
        lastLineClearTSpin: TSpinKind,
        landingFlashTimerMs: Int,
        landingFlashBlocks: [(Int, Int)],
        softDropActive: Bool,
        softDropTimeoutMs: Int,
        lockResetCount: Int,
        activeMovedSinceSpawn: Bool,
        ghostBlocks: [(Int, Int)],
        config: GameConfig
    ) {
        self.boardCells = boardCells
        self.active = active
        self.paused = paused
        self.gameOver = gameOver
        self.score = score
        self.level = level
        self.lines = lines
        self.hold = hold
        self.canHold = canHold
        self.nextQueue = nextQueue
        self.dropTimerMs = dropTimerMs
        self.lockTimerMs = lockTimerMs
        self.lineClearTimerMs = lineClearTimerMs
        self.lineClearRows = lineClearRows
        self.lineClearScore = lineClearScore
        self.lastLineClearTSpin = lastLineClearTSpin
        self.landingFlashTimerMs = landingFlashTimerMs
        self.landingFlashBlocks = landingFlashBlocks
        self.softDropActive = softDropActive
        self.softDropTimeoutMs = softDropTimeoutMs
        self.lockResetCount = lockResetCount
        self.activeMovedSinceSpawn = activeMovedSinceSpawn
        self.ghostBlocks = ghostBlocks
        self.config = config
    }

    public func canMoveDown() -> Bool {
        canMoveDown(afterSteps: 0)
    }

    public func canMoveDown(afterSteps steps: Int) -> Bool {
        let offset = max(steps, 0)
        for (dx, dy) in active.blocks(rotation: active.rotation) {
            let nx = active.x + dx
            let ny = active.y + dy + 1 + offset
            if isOccupied(x: nx, y: ny) {
                return false
            }
        }
        return true
    }

    public func willBeGroundedNextStep() -> Bool {
        canMoveDown() && !canMoveDown(afterSteps: 1)
    }

    private func isOccupied(x: Int, y: Int) -> Bool {
        guard x >= 0, x < Board.width, y >= 0, y < Board.height else { return true }
        return boardCells[y][x].filled
    }
}
