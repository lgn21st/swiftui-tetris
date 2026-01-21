public struct GameState: Equatable {
    public var board: Board
    public var active: Tetromino
    public var paused: Bool
    public var gameOver: Bool

    public var dropTimerMs: Int
    public var lockTimerMs: Int
    public var lineClearTimerMs: Int
    public var landingFlashTimerMs: Int
    public var softDropActive: Bool
    public var softDropTimeoutMs: Int
    public var lockResetCount: Int

    public private(set) var ghostCache: [(Int, Int)]
    public var config: GameConfig

    public init(config: GameConfig) {
        self.board = Board()
        let spawn = spawnPosition()
        self.active = Tetromino(kind: .i, x: spawn.x, y: spawn.y)
        self.paused = false
        self.gameOver = false
        self.dropTimerMs = 0
        self.lockTimerMs = 0
        self.lineClearTimerMs = 0
        self.landingFlashTimerMs = 0
        self.softDropActive = false
        self.softDropTimeoutMs = 0
        self.lockResetCount = 0
        self.ghostCache = []
        self.config = config
        updateGhostCache()
    }

    public mutating func tick(elapsedMs: Int, softDrop: Bool) {
        if gameOver || paused {
            return
        }

        if landingFlashTimerMs > 0 {
            landingFlashTimerMs = max(landingFlashTimerMs - elapsedMs, 0)
        }

        if lineClearTimerMs > 0 {
            lineClearTimerMs = max(lineClearTimerMs - elapsedMs, 0)
            if lineClearTimerMs > 0 {
                return
            }
        }

        dropTimerMs += max(elapsedMs, 0)
        if softDropTimeoutMs > 0 {
            softDropTimeoutMs = max(softDropTimeoutMs - elapsedMs, 0)
            if softDropTimeoutMs == 0 {
                softDropActive = false
            }
        }

        let interval = Timing.dropInterval(
            level: 0,
            baseDropMs: config.baseDropMs,
            softDrop: softDrop || softDropActive,
            softDropMultiplier: config.softDropMultiplier
        )

        while dropTimerMs >= interval {
            dropTimerMs -= interval
            _ = tryMove(dx: 0, dy: 1)
        }

        if canMoveDown() {
            lockTimerMs = 0
            lockResetCount = 0
        } else {
            lockTimerMs += max(elapsedMs, 0)
            if lockTimerMs >= config.lockDelayMs {
                lockTimerMs = 0
                dropTimerMs = 0
                lockActivePiece()
            }
        }
    }

    public mutating func activateSoftDrop() {
        softDropActive = true
        softDropTimeoutMs = config.softDropGraceMs
    }

    public func canMoveDown() -> Bool {
        board.canPlace(piece: active, x: active.x, y: active.y + 1, rotation: active.rotation)
    }

    @discardableResult
    public mutating func tryMove(dx: Int, dy: Int) -> Bool {
        let nx = active.x + dx
        let ny = active.y + dy
        if board.canPlace(piece: active, x: nx, y: ny, rotation: active.rotation) {
            active.x = nx
            active.y = ny
            updateGhostCache()
            handleLockReset()
            return true
        }
        return false
    }

    public mutating func updateGhostCache() {
        var ghostY = active.y
        while board.canPlace(piece: active, x: active.x, y: ghostY + 1, rotation: active.rotation) {
            ghostY += 1
        }
        ghostCache = active.blocks(rotation: active.rotation).map { (dx, dy) in
            (active.x + dx, ghostY + dy)
        }
    }

    public func ghostBlocks() -> [(Int, Int)] {
        ghostCache
    }

    private mutating func handleLockReset() {
        guard !canMoveDown() else {
            lockTimerMs = 0
            lockResetCount = 0
            return
        }
        if lockResetCount < config.lockResetLimit {
            lockTimerMs = 0
            lockResetCount += 1
        }
    }

    private mutating func lockActivePiece() {
        setLandingFlash()
        board.lock(piece: active)
        let cleared = board.clearLines()
        if cleared > 0 {
            lineClearTimerMs = 180
        }
        let spawn = spawnPosition()
        active = Tetromino(kind: .i, x: spawn.x, y: spawn.y)
        updateGhostCache()
        if !board.canPlace(piece: active, x: active.x, y: active.y, rotation: active.rotation) {
            gameOver = true
        }
    }

    private mutating func setLandingFlash() {
        landingFlashTimerMs = 120
    }
}
