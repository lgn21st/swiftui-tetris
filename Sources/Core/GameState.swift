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
    public var lastActionRotate: Bool
    public var hold: TetrominoType?
    public var canHold: Bool
    public var nextQueue: [TetrominoType]

    public private(set) var dropTimerMs: Int
    public private(set) var lockTimerMs: Int
    public private(set) var lineClearTimerMs: Int
    public var lineClearRows: [Int]
    public var lineClearScore: Int
    public private(set) var lastLineClearTSpin: TSpinKind
    public private(set) var landingFlashTimerMs: Int
    public var landingFlashBlocks: [(Int, Int)]
    public var softDropActive: Bool
    public private(set) var softDropTimeoutMs: Int
    public private(set) var lockResetCount: Int
    public var activeMovedSinceSpawn: Bool

    public private(set) var ghostCache: [(Int, Int)]
    public var config: GameConfig
    public var rng: SimpleRng
    private var soundEvents: [SoundEvent]

    public init(config: GameConfig, seed: UInt64 = 1) {
        self.board = Board()
        self.rng = SimpleRng(seed: seed)
        self.nextQueue = []
        QueueRng.ensureQueue(rng: &self.rng, queue: &self.nextQueue, minimum: 4)
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
        self.lastActionRotate = false
        self.hold = nil
        self.canHold = true
        self.dropTimerMs = 0
        self.lockTimerMs = 0
        self.lineClearTimerMs = 0
        self.lineClearRows = []
        self.lineClearScore = 0
        self.lastLineClearTSpin = .none
        self.landingFlashTimerMs = 0
        self.landingFlashBlocks = []
        self.softDropActive = false
        self.softDropTimeoutMs = 0
        self.lockResetCount = 0
        self.activeMovedSinceSpawn = false
        self.ghostCache = []
        self.config = config
        self.soundEvents = []
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
            lineClearRows = []
            lineClearScore = 0
            lastLineClearTSpin = .none
        }

        dropTimerMs += max(elapsedMs, 0)
        if softDropTimeoutMs > 0 {
            softDropTimeoutMs = max(softDropTimeoutMs - elapsedMs, 0)
            if softDropTimeoutMs == 0 {
                softDropActive = false
            }
        }

        let interval = Timing.dropInterval(
            level: level,
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
            lastActionRotate = false
            soundEvents.append(.move)
        case .moveRight:
            _ = tryMove(dx: 1, dy: 0)
            lastActionRotate = false
            soundEvents.append(.move)
        case .softDrop:
            _ = softDropStep()
            lastActionRotate = false
            soundEvents.append(.softDrop)
        case .hardDrop:
            _ = hardDrop()
            lastActionRotate = false
            soundEvents.append(.hardDrop)
        case .rotateCw:
            lastActionRotate = rotate(clockwise: true)
            soundEvents.append(.rotate)
        case .rotateCcw:
            lastActionRotate = rotate(clockwise: false)
            soundEvents.append(.rotate)
        case .hold:
            _ = holdAction()
            lastActionRotate = false
            soundEvents.append(.hold)
        case .pause:
            paused.toggle()
            if paused {
                softDropActive = false
                softDropTimeoutMs = 0
            }
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
            activeMovedSinceSpawn = true
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
                activeMovedSinceSpawn = true
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

    public mutating func applyLineClear(cleared: Int, clearedRows: [Int], tSpin: TSpinKind = .none) {
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
            lineClearTimerMs = GameConstants.lineClearPauseMs
            lineClearRows = clearedRows
            lineClearScore = points
            lastLineClearTSpin = tSpin
            soundEvents.append(.lineClear(cleared))
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
            lineClearRows = []
            lineClearScore = 0
            lastLineClearTSpin = .none
        }

        if points > 0 {
            score += points
        }
    }

    private mutating func lockActivePiece() {
        setLandingFlash()
        board.lock(piece: active)
        let result = board.clearLines()
        let tSpin = config.ruleset == .modern ? tSpinKind() : .none
        applyLineClear(cleared: result.count, clearedRows: result.rows, tSpin: tSpin)
        lastActionRotate = false
        spawnNext()
    }

    private mutating func setLandingFlash() {
        landingFlashTimerMs = GameConstants.landingFlashDurationMs
        landingFlashBlocks = active.blocks(rotation: active.rotation).map { (dx, dy) in
            (active.x + dx, active.y + dy)
        }
    }

    private mutating func spawnPiece(kind: TetrominoType) -> Tetromino {
        let spawn = spawnPosition()
        let piece = Tetromino(kind: kind, x: spawn.x, y: spawn.y)
        if !board.canPlace(piece: piece, x: piece.x, y: piece.y, rotation: piece.rotation) {
            gameOver = true
            soundEvents.append(.gameOver)
        }
        updateGhostCache()
        lockResetCount = 0
        lastActionRotate = false
        activeMovedSinceSpawn = false
        return piece
    }

    public mutating func spawnNext() {
        QueueRng.ensureQueue(rng: &rng, queue: &nextQueue, minimum: 4)
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

    public func tSpinKind() -> TSpinKind {
        guard active.kind == .t, lastActionRotate else { return .none }
        let centerX = active.x + 1
        let centerY = active.y + 1
        let corners = [
            (centerX - 1, centerY - 1),
            (centerX + 1, centerY - 1),
            (centerX - 1, centerY + 1),
            (centerX + 1, centerY + 1)
        ]
        var filled = 0
        for (x, y) in corners {
            if board.isOccupied(x: x, y: y) {
                filled += 1
            }
        }
        if filled < 3 { return .none }

        let front: [(Int, Int)]
        switch active.rotation {
        case .north:
            front = [(centerX - 1, centerY - 1), (centerX + 1, centerY - 1)]
        case .east:
            front = [(centerX + 1, centerY - 1), (centerX + 1, centerY + 1)]
        case .south:
            front = [(centerX - 1, centerY + 1), (centerX + 1, centerY + 1)]
        case .west:
            front = [(centerX - 1, centerY - 1), (centerX - 1, centerY + 1)]
        }
        let frontFilled = front.filter { board.isOccupied(x: $0.0, y: $0.1) }.count
        return frontFilled == 2 ? .full : .mini
    }

    public mutating func takeSoundEvents() -> [SoundEvent] {
        let events = soundEvents
        soundEvents.removeAll()
        return events
    }

    public func snapshot() -> GameStateSnapshot {
        GameStateSnapshot(
            boardCells: board.cells,
            active: active,
            paused: paused,
            gameOver: gameOver,
            score: score,
            level: level,
            lines: lines,
            hold: hold,
            canHold: canHold,
            nextQueue: nextQueue,
            dropTimerMs: dropTimerMs,
            lockTimerMs: lockTimerMs,
            lineClearTimerMs: lineClearTimerMs,
            lineClearRows: lineClearRows,
            lineClearScore: lineClearScore,
            lastLineClearTSpin: lastLineClearTSpin,
            landingFlashTimerMs: landingFlashTimerMs,
            landingFlashBlocks: landingFlashBlocks,
            softDropActive: softDropActive,
            softDropTimeoutMs: softDropTimeoutMs,
            lockResetCount: lockResetCount,
            activeMovedSinceSpawn: activeMovedSinceSpawn,
            ghostBlocks: ghostCache,
            config: config
        )
    }

    internal mutating func setTimersForTesting(
        dropTimerMs: Int? = nil,
        lockTimerMs: Int? = nil,
        lineClearTimerMs: Int? = nil,
        landingFlashTimerMs: Int? = nil,
        softDropTimeoutMs: Int? = nil,
        lockResetCount: Int? = nil
    ) {
        if let dropTimerMs { self.dropTimerMs = dropTimerMs }
        if let lockTimerMs { self.lockTimerMs = lockTimerMs }
        if let lineClearTimerMs { self.lineClearTimerMs = lineClearTimerMs }
        if let landingFlashTimerMs { self.landingFlashTimerMs = landingFlashTimerMs }
        if let softDropTimeoutMs { self.softDropTimeoutMs = softDropTimeoutMs }
        if let lockResetCount { self.lockResetCount = lockResetCount }
    }
}
