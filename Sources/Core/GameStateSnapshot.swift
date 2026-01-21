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
        self.ghostBlocks = ghostBlocks
        self.config = config
    }
}
