import Core
import Foundation

public enum TetrisAIPieceKind: String, CaseIterable, Equatable, Codable {
    case i
    case o
    case t
    case s
    case z
    case j
    case l

    public init?(tetromino: TetrominoType) {
        switch tetromino {
        case .i: self = .i
        case .o: self = .o
        case .t: self = .t
        case .s: self = .s
        case .z: self = .z
        case .j: self = .j
        case .l: self = .l
        }
    }

    public var cellCode: Int {
        switch self {
        case .i: return 1
        case .o: return 2
        case .t: return 3
        case .s: return 4
        case .z: return 5
        case .j: return 6
        case .l: return 7
        }
    }

    public func toTetrominoType() -> TetrominoType {
        switch self {
        case .i: return .i
        case .o: return .o
        case .t: return .t
        case .s: return .s
        case .z: return .z
        case .j: return .j
        case .l: return .l
        }
    }
}

public enum TetrisAIRotation: String, CaseIterable, Equatable, Codable {
    case north
    case east
    case south
    case west

    public init(rotation: Rotation) {
        switch rotation {
        case .north: self = .north
        case .east: self = .east
        case .south: self = .south
        case .west: self = .west
        }
    }

    public func toRotation() -> Rotation {
        switch self {
        case .north: return .north
        case .east: return .east
        case .south: return .south
        case .west: return .west
        }
    }
}

public enum TetrisAIAction: String, Equatable, Codable {
    case moveLeft
    case moveRight
    case softDrop
    case hardDrop
    case rotateCw
    case rotateCcw
    case hold
    case pause
    case restart
}

public enum TetrisAICommand: Equatable, Codable {
    case action(actions: [TetrisAIAction])
    case place(x: Int, rotation: TetrisAIRotation, useHold: Bool)
}

public enum TetrisAITSpinKind: String, Equatable, Codable {
    case mini
    case full
}

public struct TetrisAILastEvent: Equatable, Codable {
    public var locked: Bool
    public var linesCleared: Int
    public var lineClearScore: Int
    public var tspin: TetrisAITSpinKind?
    public var combo: Int
    public var backToBack: Bool

    public init(
        locked: Bool,
        linesCleared: Int,
        lineClearScore: Int,
        tspin: TetrisAITSpinKind?,
        combo: Int,
        backToBack: Bool
    ) {
        self.locked = locked
        self.linesCleared = linesCleared
        self.lineClearScore = lineClearScore
        self.tspin = tspin
        self.combo = combo
        self.backToBack = backToBack
    }

    private enum CodingKeys: String, CodingKey {
        case locked
        case linesCleared = "lines_cleared"
        case lineClearScore = "line_clear_score"
        case tspin
        case combo
        case backToBack = "back_to_back"
    }
}

public struct TetrisAIObservation: Equatable, Codable {
    public var seq: Int
    public var tsMs: Int
    public var playable: Bool
    public var paused: Bool
    public var gameOver: Bool
    public var episodeId: Int
    public var seed: UInt64
    public var pieceId: Int
    public var stepInPiece: Int
    public var board: TetrisAIObservationBoard
    public var boardId: Int
    public var active: TetrisAIObservationActive?
    public var ghostY: Int?
    public var next: TetrisAIPieceKind
    public var nextQueue: [TetrisAIPieceKind]
    public var hold: TetrisAIPieceKind?
    public var canHold: Bool
    public var lastEvent: TetrisAILastEvent?
    public var stateHash: String
    public var score: Int
    public var level: Int
    public var lines: Int
    public var timers: TetrisAIObservationTimers

    public init(
        seq: Int,
        tsMs: Int,
        playable: Bool,
        paused: Bool,
        gameOver: Bool,
        episodeId: Int,
        seed: UInt64,
        pieceId: Int,
        stepInPiece: Int,
        board: TetrisAIObservationBoard,
        boardId: Int,
        active: TetrisAIObservationActive?,
        ghostY: Int?,
        next: TetrisAIPieceKind,
        nextQueue: [TetrisAIPieceKind],
        hold: TetrisAIPieceKind?,
        canHold: Bool,
        lastEvent: TetrisAILastEvent?,
        stateHash: String,
        score: Int,
        level: Int,
        lines: Int,
        timers: TetrisAIObservationTimers
    ) {
        self.seq = seq
        self.tsMs = tsMs
        self.playable = playable
        self.paused = paused
        self.gameOver = gameOver
        self.episodeId = episodeId
        self.seed = seed
        self.pieceId = pieceId
        self.stepInPiece = stepInPiece
        self.board = board
        self.boardId = boardId
        self.active = active
        self.ghostY = ghostY
        self.next = next
        self.nextQueue = nextQueue
        self.hold = hold
        self.canHold = canHold
        self.lastEvent = lastEvent
        self.stateHash = stateHash
        self.score = score
        self.level = level
        self.lines = lines
        self.timers = timers
    }

    private enum CodingKeys: String, CodingKey {
        case seq
        case tsMs = "ts"
        case playable
        case paused
        case gameOver = "game_over"
        case episodeId = "episode_id"
        case seed
        case pieceId = "piece_id"
        case stepInPiece = "step_in_piece"
        case board
        case boardId = "board_id"
        case active
        case ghostY = "ghost_y"
        case next
        case nextQueue = "next_queue"
        case hold
        case canHold = "can_hold"
        case lastEvent = "last_event"
        case stateHash = "state_hash"
        case score
        case level
        case lines
        case timers
    }
}

public struct TetrisAIObservationBoard: Equatable, Codable {
    public var width: Int
    public var height: Int
    public var cells: [[Int]]

    public init(width: Int, height: Int, cells: [[Int]]) {
        self.width = width
        self.height = height
        self.cells = cells
    }

    public static func empty() -> TetrisAIObservationBoard {
        let row = Array(repeating: 0, count: Board.width)
        return TetrisAIObservationBoard(
            width: Board.width,
            height: Board.height,
            cells: Array(repeating: row, count: Board.height)
        )
    }
}

public struct TetrisAIObservationActive: Equatable, Codable {
    public var kind: TetrisAIPieceKind
    public var rotation: TetrisAIRotation
    public var x: Int
    public var y: Int

    public init(kind: TetrisAIPieceKind, rotation: TetrisAIRotation, x: Int, y: Int) {
        self.kind = kind
        self.rotation = rotation
        self.x = x
        self.y = y
    }
}

public struct TetrisAIObservationTimers: Equatable, Codable {
    public var dropMs: Int
    public var lockMs: Int
    public var lineClearMs: Int

    public init(dropMs: Int, lockMs: Int, lineClearMs: Int) {
        self.dropMs = dropMs
        self.lockMs = lockMs
        self.lineClearMs = lineClearMs
    }

    private enum CodingKeys: String, CodingKey {
        case dropMs = "drop_ms"
        case lockMs = "lock_ms"
        case lineClearMs = "line_clear_ms"
    }
}

public enum CommandMappingError: Error, Equatable {
    case unsupportedMode
    case snapshotRequired
    case holdUnavailable
    case invalidPlace
}

public enum CommandMapper {
    public static func map(command: TetrisAICommand, snapshot: GameStateSnapshot?) throws -> [GameAction] {
        switch command {
        case .action(let actions):
            return actions.map { mapAction($0) }
        case .place(let x, let rotation, let useHold):
            guard let snapshot else { throw CommandMappingError.snapshotRequired }
            return try mapPlace(x: x, rotation: rotation, useHold: useHold, snapshot: snapshot)
        }
    }

    private static func mapAction(_ action: TetrisAIAction) -> GameAction {
        switch action {
        case .moveLeft: return .moveLeft
        case .moveRight: return .moveRight
        case .softDrop: return .softDrop
        case .hardDrop: return .hardDrop
        case .rotateCw: return .rotateCw
        case .rotateCcw: return .rotateCcw
        case .hold: return .hold
        case .pause: return .pause
        case .restart: return .restart
        }
    }

    private static func mapPlace(
        x: Int,
        rotation: TetrisAIRotation,
        useHold: Bool,
        snapshot: GameStateSnapshot
    ) throws -> [GameAction] {
        var actions: [GameAction] = []
        let originalSnapshot = snapshot
        var planningSnapshot = snapshot
        var activeStart = snapshot.active

        if useHold {
            guard snapshot.canHold else { throw CommandMappingError.holdUnavailable }
            actions.append(.hold)
            let heldKind = snapshot.hold ?? snapshot.nextQueue.first
            guard let kind = heldKind else { throw CommandMappingError.holdUnavailable }
            let spawn = spawnPosition()
            activeStart = Tetromino(kind: kind, x: spawn.x, y: spawn.y)
            activeStart.rotation = .north
            planningSnapshot = GameStateSnapshot(
                episodeId: snapshot.episodeId,
                seed: snapshot.seed,
                pieceId: snapshot.pieceId + 1,
                stepInPiece: 0,
                boardCells: snapshot.boardCells,
                active: activeStart,
                paused: snapshot.paused,
                gameOver: snapshot.gameOver,
                score: snapshot.score,
                level: snapshot.level,
                lines: snapshot.lines,
                combo: snapshot.combo,
                backToBack: snapshot.backToBack,
                hold: snapshot.hold,
                canHold: false,
                nextQueue: snapshot.nextQueue,
                dropTimerMs: snapshot.dropTimerMs,
                lockTimerMs: snapshot.lockTimerMs,
                lineClearTimerMs: snapshot.lineClearTimerMs,
                lineClearRows: snapshot.lineClearRows,
                lineClearScore: snapshot.lineClearScore,
                lastLineClearTSpin: snapshot.lastLineClearTSpin,
                landingFlashTimerMs: snapshot.landingFlashTimerMs,
                landingFlashBlocks: snapshot.landingFlashBlocks,
                softDropActive: snapshot.softDropActive,
                softDropTimeoutMs: snapshot.softDropTimeoutMs,
                lockResetCount: snapshot.lockResetCount,
                activeMovedSinceSpawn: snapshot.activeMovedSinceSpawn,
                adapterLocked: false,
                ghostBlocks: snapshot.ghostBlocks,
                config: snapshot.config
            )
        }

        let targetRotation = rotation.toRotation()
        guard let plan = PlacePlanner.plan(
            snapshot: planningSnapshot,
            targetX: x,
            targetRotation: targetRotation
        ) else {
            throw CommandMappingError.invalidPlace
        }

        actions.append(contentsOf: plan)
        actions.append(.hardDrop)
        if !validateActionPath(actions: actions, snapshot: originalSnapshot, targetX: x, targetRotation: targetRotation) {
            throw CommandMappingError.invalidPlace
        }
        return actions
    }

    private static func rotationActions(from: Rotation, to: Rotation) -> [GameAction] {
        let fromValue = from.rawValue
        let toValue = to.rawValue
        let cwSteps = (toValue - fromValue + 4) % 4
        let ccwSteps = (fromValue - toValue + 4) % 4
        if cwSteps == 0 {
            return []
        }
        if cwSteps <= ccwSteps {
            return Array(repeating: .rotateCw, count: cwSteps)
        }
        return Array(repeating: .rotateCcw, count: ccwSteps)
    }

    private static func canPlace(piece: Tetromino, board: [[Cell]]) -> Bool {
        for (dx, dy) in piece.blocks(rotation: piece.rotation) {
            let nx = piece.x + dx
            let ny = piece.y + dy
            if nx < 0 || nx >= Board.width || ny < 0 || ny >= Board.height {
                return false
            }
            if board[ny][nx].filled {
                return false
            }
        }
        return true
    }

    private static func canDrop(piece: Tetromino, board: [[Cell]]) -> Bool {
        var falling = piece
        guard canPlace(piece: falling, board: board) else { return false }
        while true {
            var next = falling
            next.y += 1
            if canPlace(piece: next, board: board) {
                falling = next
            } else {
                break
            }
        }
        return true
    }

    private static func validateActionPath(
        actions: [GameAction],
        snapshot: GameStateSnapshot,
        targetX: Int,
        targetRotation: Rotation
    ) -> Bool {
        var state = GameState(config: snapshot.config, seed: 1)
        state.board.cells = snapshot.boardCells
        state.active = snapshot.active
        state.hold = snapshot.hold
        state.canHold = snapshot.canHold
        state.nextQueue = snapshot.nextQueue
        state.paused = snapshot.paused
        state.gameOver = snapshot.gameOver
        state.updateGhostCache()

        let actionsToValidate = actions.dropLast()
        for action in actionsToValidate {
            let prevActive = state.active
            let prevHold = state.hold
            let prevCanHold = state.canHold
            state.apply(action: action)

            switch action {
            case .moveLeft, .moveRight, .rotateCw, .rotateCcw:
                if state.active == prevActive {
                    return false
                }
            case .hold:
                if state.active.kind == prevActive.kind && state.hold == prevHold && state.canHold == prevCanHold {
                    return false
                }
            default:
                break
            }
        }

        return state.active.x == targetX
            && state.active.rotation == targetRotation
            && state.board.canPlace(piece: state.active, x: state.active.x, y: state.active.y, rotation: state.active.rotation)
    }
}

public enum ObservationMapper {
    public static func map(snapshot: GameStateSnapshot, seq: Int, tsMs: Int) -> TetrisAIObservation {
        let boardCells = mapBoardCells(snapshot.boardCells)
        let board = TetrisAIObservationBoard(width: Board.width, height: Board.height, cells: boardCells)
        let boardId = boardId(boardCells)
        let active = mapActive(snapshot.active)
        let nextQueue = snapshot.nextQueue.prefix(5).compactMap { TetrisAIPieceKind(tetromino: $0) }
        let next = nextQueue.first ?? .i
        let hold = snapshot.hold.flatMap { TetrisAIPieceKind(tetromino: $0) }
        let timers = TetrisAIObservationTimers(
            dropMs: snapshot.dropTimerMs,
            lockMs: snapshot.lockTimerMs,
            lineClearMs: snapshot.lineClearTimerMs
        )

        let tspin: TetrisAITSpinKind?
        switch snapshot.lastLineClearTSpin {
        case .none: tspin = nil
        case .mini: tspin = .mini
        case .full: tspin = .full
        }

        let lastEvent: TetrisAILastEvent?
        if snapshot.adapterLocked || !snapshot.lineClearRows.isEmpty {
            lastEvent = TetrisAILastEvent(
                locked: snapshot.adapterLocked,
                linesCleared: snapshot.lineClearRows.count,
                lineClearScore: snapshot.lineClearScore,
                tspin: tspin,
                combo: snapshot.combo,
                backToBack: snapshot.backToBack
            )
        } else {
            lastEvent = nil
        }

        return TetrisAIObservation(
            seq: seq,
            tsMs: tsMs,
            playable: !snapshot.paused && !snapshot.gameOver,
            paused: snapshot.paused,
            gameOver: snapshot.gameOver,
            episodeId: snapshot.episodeId,
            seed: snapshot.seed,
            pieceId: snapshot.pieceId,
            stepInPiece: snapshot.stepInPiece,
            board: board,
            boardId: boardId,
            active: active,
            ghostY: ghostY(snapshot: snapshot),
            next: next,
            nextQueue: nextQueue,
            hold: hold,
            canHold: snapshot.canHold,
            lastEvent: lastEvent,
            stateHash: stateHash(snapshot),
            score: snapshot.score,
            level: snapshot.level,
            lines: snapshot.lines,
            timers: timers
        )
    }

    private static func ghostY(snapshot: GameStateSnapshot) -> Int? {
        guard !snapshot.ghostBlocks.isEmpty else { return nil }
        guard let first = snapshot.active.blocks(rotation: snapshot.active.rotation).first else { return nil }
        let activeOrigin = (x: snapshot.active.x, y: snapshot.active.y)
        let expectedFirst = (x: activeOrigin.x + first.0, y: activeOrigin.y + first.1)
        guard let ghostFirst = snapshot.ghostBlocks.first else { return nil }
        let delta = ghostFirst.1 - expectedFirst.y
        return snapshot.active.y + delta
    }

    private static func boardId(_ cells: [[Int]]) -> Int {
        var hash: UInt32 = 2166136261
        for row in cells {
            for value in row {
                hash ^= UInt32(truncatingIfNeeded: value)
                hash &*= 16777619
            }
        }
        return Int(hash)
    }

    private static func stateHash(_ snapshot: GameStateSnapshot) -> String {
        var hash: UInt64 = 14695981039346656037

        func mixByte(_ b: UInt8) {
            hash ^= UInt64(b)
            hash &*= 1099511628211
        }

        func mixUInt64(_ v: UInt64) {
            var x = v
            for _ in 0..<8 {
                mixByte(UInt8(truncatingIfNeeded: x))
                x >>= 8
            }
        }

        mixUInt64(UInt64(snapshot.episodeId))
        mixUInt64(snapshot.seed)
        mixUInt64(UInt64(snapshot.pieceId))
        mixUInt64(UInt64(snapshot.stepInPiece))

        for row in snapshot.boardCells {
            for cell in row {
                mixByte(cell.filled ? 1 : 0)
                if let kind = cell.kind {
                    mixByte(UInt8(kind.rawValue))
                } else {
                    mixByte(0)
                }
            }
        }

        mixByte(UInt8(snapshot.active.kind.rawValue))
        mixByte(UInt8(snapshot.active.rotation.rawValue))
        mixUInt64(UInt64(snapshot.active.x))
        mixUInt64(UInt64(snapshot.active.y))
        if let hold = snapshot.hold {
            mixByte(UInt8(hold.rawValue))
        } else {
            mixByte(0)
        }
        mixByte(snapshot.canHold ? 1 : 0)
        for kind in snapshot.nextQueue {
            mixByte(UInt8(kind.rawValue))
        }

        return String(format: "%016llx", hash)
    }

    private static func mapBoardCells(_ cells: [[Cell]]) -> [[Int]] {
        var mapped: [[Int]] = []
        mapped.reserveCapacity(cells.count)
        for row in cells {
            var mappedRow: [Int] = []
            mappedRow.reserveCapacity(row.count)
            for cell in row {
                guard cell.filled, let kind = cell.kind, let mappedKind = TetrisAIPieceKind(tetromino: kind) else {
                    mappedRow.append(0)
                    continue
                }
                mappedRow.append(mappedKind.cellCode)
            }
            mapped.append(mappedRow)
        }
        return mapped
    }

    private static func mapActive(_ active: Tetromino) -> TetrisAIObservationActive? {
        guard let kind = TetrisAIPieceKind(tetromino: active.kind) else { return nil }
        return TetrisAIObservationActive(
            kind: kind,
            rotation: TetrisAIRotation(rotation: active.rotation),
            x: active.x,
            y: active.y
        )
    }
}
