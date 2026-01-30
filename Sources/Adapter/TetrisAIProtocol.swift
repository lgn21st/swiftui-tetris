import Core
import Foundation

public enum TetrisAIPieceKind: String, CaseIterable, Equatable, Codable {
    case i = "I"
    case o = "O"
    case t = "T"
    case s = "S"
    case z = "Z"
    case j = "J"
    case l = "L"

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

public struct TetrisAIObservation: Equatable, Codable {
    public var seq: Int
    public var tsMs: Int
    public var playable: Bool
    public var board: TetrisAIObservationBoard
    public var active: TetrisAIObservationActive?
    public var next: TetrisAIPieceKind?
    public var hold: TetrisAIPieceKind?
    public var score: Int
    public var level: Int
    public var lines: Int
    public var timers: TetrisAIObservationTimers

    public init(
        seq: Int,
        tsMs: Int,
        playable: Bool,
        board: TetrisAIObservationBoard,
        active: TetrisAIObservationActive?,
        next: TetrisAIPieceKind?,
        hold: TetrisAIPieceKind?,
        score: Int,
        level: Int,
        lines: Int,
        timers: TetrisAIObservationTimers
    ) {
        self.seq = seq
        self.tsMs = tsMs
        self.playable = playable
        self.board = board
        self.active = active
        self.next = next
        self.hold = hold
        self.score = score
        self.level = level
        self.lines = lines
        self.timers = timers
    }

    private enum CodingKeys: String, CodingKey {
        case seq
        case tsMs = "ts"
        case playable
        case board
        case active
        case next
        case hold
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
    public var kinds: [[TetrisAIPieceKind?]]

    public init(width: Int, height: Int, cells: [[Int]], kinds: [[TetrisAIPieceKind?]]) {
        self.width = width
        self.height = height
        self.cells = cells
        self.kinds = kinds
    }

    public static func empty() -> TetrisAIObservationBoard {
        let row = Array(repeating: 0, count: Board.width)
        let kindRow = Array(repeating: TetrisAIPieceKind?.none, count: Board.width)
        return TetrisAIObservationBoard(
            width: Board.width,
            height: Board.height,
            cells: Array(repeating: row, count: Board.height),
            kinds: Array(repeating: kindRow, count: Board.height)
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
        var activeStart = snapshot.active

        if useHold {
            guard snapshot.canHold else { throw CommandMappingError.holdUnavailable }
            actions.append(.hold)
            let heldKind = snapshot.hold ?? snapshot.nextQueue.first
            guard let kind = heldKind else { throw CommandMappingError.holdUnavailable }
            let spawn = spawnPosition()
            activeStart = Tetromino(kind: kind, x: spawn.x, y: spawn.y)
            activeStart.rotation = .north
        }

        let targetRotation = rotation.toRotation()
        var targetPiece = activeStart
        targetPiece.rotation = targetRotation
        targetPiece.x = x
        if !canPlace(piece: targetPiece, board: snapshot.boardCells) {
            throw CommandMappingError.invalidPlace
        }
        if !canDrop(piece: targetPiece, board: snapshot.boardCells) {
            throw CommandMappingError.invalidPlace
        }

        actions.append(contentsOf: rotationActions(from: activeStart.rotation, to: targetRotation))

        let dx = x - activeStart.x
        if dx < 0 {
            for _ in 0..<(-dx) { actions.append(.moveLeft) }
        } else if dx > 0 {
            for _ in 0..<dx { actions.append(.moveRight) }
        }

        actions.append(.hardDrop)
        if !validateActionPath(actions: actions, snapshot: snapshot, targetX: x, targetRotation: targetRotation) {
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
        let board = mapBoard(snapshot.boardCells)
        let active = mapActive(snapshot.active)
        let next = snapshot.nextQueue.first.flatMap { TetrisAIPieceKind(tetromino: $0) }
        let hold = snapshot.hold.flatMap { TetrisAIPieceKind(tetromino: $0) }
        let timers = TetrisAIObservationTimers(
            dropMs: snapshot.dropTimerMs,
            lockMs: snapshot.lockTimerMs,
            lineClearMs: snapshot.lineClearTimerMs
        )

        return TetrisAIObservation(
            seq: seq,
            tsMs: tsMs,
            playable: !snapshot.paused && !snapshot.gameOver,
            board: board,
            active: active,
            next: next,
            hold: hold,
            score: snapshot.score,
            level: snapshot.level,
            lines: snapshot.lines,
            timers: timers
        )
    }

    private static func mapBoard(_ cells: [[Cell]]) -> TetrisAIObservationBoard {
        var filled: [[Int]] = []
        var kinds: [[TetrisAIPieceKind?]] = []

        filled.reserveCapacity(cells.count)
        kinds.reserveCapacity(cells.count)

        for row in cells {
            var filledRow: [Int] = []
            var kindRow: [TetrisAIPieceKind?] = []
            filledRow.reserveCapacity(row.count)
            kindRow.reserveCapacity(row.count)

            for cell in row {
                filledRow.append(cell.filled ? 1 : 0)
                if let kind = cell.kind, let mapped = TetrisAIPieceKind(tetromino: kind) {
                    kindRow.append(mapped)
                } else {
                    kindRow.append(nil)
                }
            }

            filled.append(filledRow)
            kinds.append(kindRow)
        }

        return TetrisAIObservationBoard(
            width: Board.width,
            height: Board.height,
            cells: filled,
            kinds: kinds
        )
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
