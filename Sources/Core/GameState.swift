public struct GameState {
    public var board: Board
    public var active: Tetromino
    public var paused: Bool
    public var gameOver: Bool
    public var score: Int
    public var level: Int
    public var lines: Int
    public var combo: Int
    public var backToBack: Bool
    public var hold: TetrominoType?
    public var canHold: Bool
    public var nextQueue: [TetrominoType]

    public var dropTimerMs: Int
    public var lockTimerMs: Int
    public var lineClearTimerMs: Int
    public var landingFlashTimerMs: Int
    public var softDropActive: Bool
    public var softDropTimeoutMs: Int
    public var lockResetCount: Int

    public private(set) var ghostCache: [(Int, Int)]
    public var config: GameConfig
    public var rng: SimpleRng

    public init(config: GameConfig, seed: UInt64 = 1) {
        self.board = Board()
        self.rng = SimpleRng(seed: seed)
        self.nextQueue = []
        QueueRng.ensureQueue(rng: &self.rng, queue: &self.nextQueue, minimum: 5)
        let spawn = spawnPosition()
        let firstKind = nextQueue.isEmpty ? TetrominoType.i : nextQueue.removeFirst()
        self.active = Tetromino(kind: firstKind, x: spawn.x, y: spawn.y)
        self.paused = false
        self.gameOver = false
        self.score = 0
        self.level = 0
        self.lines = 0
        self.combo = -1
        self.backToBack = false
        self.hold = nil
        self.canHold = true
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

    public mutating func apply(action: GameAction) {
        if gameOver && action != .restart {
            return
        }
        if paused && action != .pause && action != .restart {
            return
        }

        switch action {
        case .moveLeft:
            _ = tryMove(dx: -1, dy: 0)
        case .moveRight:
            _ = tryMove(dx: 1, dy: 0)
        case .softDrop:
            _ = softDropStep()
        case .hardDrop:
            _ = hardDrop()
        case .rotateCw:
            _ = rotate(clockwise: true)
        case .rotateCcw:
            _ = rotate(clockwise: false)
        case .hold:
            _ = holdAction()
        case .pause:
            paused.toggle()
        case .restart:
            restart(seed: rngSeed())
        }
    }

    @discardableResult
    public mutating func softDropStep() -> Bool {
        let moved = tryMove(dx: 0, dy: 1)
        if moved {
            score += 1
        }
        activateSoftDrop()
        return moved
    }

    @discardableResult
    public mutating func hardDrop() -> Int {
        var dropped = 0
        while tryMove(dx: 0, dy: 1) {
            dropped += 1
        }
        if dropped > 0 {
            score += dropped * 2
        }
        lockActivePiece()
        dropTimerMs = 0
        lockTimerMs = 0
        return dropped
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

    @discardableResult
    public mutating func holdAction() -> Bool {
        guard canHold else { return false }
        let currentKind = active.kind
        if let held = hold {
            hold = currentKind
            active = spawnPiece(kind: held)
        } else {
            hold = currentKind
            spawnNext()
        }
        canHold = false
        return true
    }

    @discardableResult
    public mutating func rotate(clockwise: Bool) -> Bool {
        let nextRotation = clockwise ? active.rotation.cw() : active.rotation.ccw()
        let kicks = srsKicks(kind: active.kind, from: active.rotation, to: nextRotation)
        for (dx, dy) in kicks {
            let nx = active.x + dx
            let ny = active.y + dy
            if board.canPlace(piece: active, x: nx, y: ny, rotation: nextRotation) {
                active.x = nx
                active.y = ny
                active.rotation = nextRotation
                updateGhostCache()
                handleLockReset()
                return true
            }
        }
        return false
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

    public mutating func applyLineClear(cleared: Int, tSpin: TSpinKind = .none) {
        guard cleared >= 0 else { return }
        var points = 0
        let qualifiesB2B = (tSpin == .full && cleared > 0) || cleared == 4

        if config.ruleset == .classic {
            points = Scoring.classicScore(linesCleared: cleared, level: level)
        } else {
            switch tSpin {
            case .full:
                points = Scoring.modernScore(linesCleared: cleared, level: level, table: config.rules.tSpinFull)
            case .mini:
                points = Scoring.modernScore(linesCleared: cleared, level: level, table: config.rules.tSpinMini)
            case .none:
                points = Scoring.classicScore(linesCleared: cleared, level: level)
            }

            if qualifiesB2B && backToBack {
                points = points * config.rules.b2bBonusNum / config.rules.b2bBonusDen
            }
        }

        if cleared > 0 {
            lineClearTimerMs = 180
            lines += cleared
            if config.ruleset == .modern {
                combo += 1
                if combo > 0 {
                    points += config.rules.comboBase * combo
                }
                backToBack = qualifiesB2B
            } else {
                combo = -1
                backToBack = false
            }
            level = lines / 10
        } else {
            combo = -1
            backToBack = false
        }

        if points > 0 {
            score += points
        }
    }

    private mutating func lockActivePiece() {
        setLandingFlash()
        board.lock(piece: active)
        let cleared = board.clearLines()
        applyLineClear(cleared: cleared)
        spawnNext()
    }

    private mutating func setLandingFlash() {
        landingFlashTimerMs = 120
    }

    private mutating func spawnPiece(kind: TetrominoType) -> Tetromino {
        let spawn = spawnPosition()
        let piece = Tetromino(kind: kind, x: spawn.x, y: spawn.y)
        if !board.canPlace(piece: piece, x: piece.x, y: piece.y, rotation: piece.rotation) {
            gameOver = true
        }
        updateGhostCache()
        lockResetCount = 0
        return piece
    }

    public mutating func spawnNext() {
        QueueRng.ensureQueue(rng: &rng, queue: &nextQueue, minimum: 5)
        let next = nextQueue.removeFirst()
        active = spawnPiece(kind: next)
        canHold = true
    }

    public mutating func restart(seed: UInt64) {
        self = GameState(config: config, seed: seed)
    }

    private mutating func rngSeed() -> UInt64 {
        UInt64(rng.nextUInt32())
    }
}
