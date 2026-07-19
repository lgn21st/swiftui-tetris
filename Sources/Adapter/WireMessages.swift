import Foundation
import Core

public enum TetrisAIFormat: String, Codable, Equatable, Sendable {
    case json
}

public enum TetrisAICommandMode: String, Codable, Equatable, Sendable {
    case action
    case place
}

public enum TetrisAIControlAction: String, Codable, Equatable {
    case claim
    case release
}

public enum TetrisAIRole: String, Codable, Equatable {
    case auto
    case controller
    case observer
}

public struct TetrisAIClientInfo: Codable, Equatable {
    public var name: String
    public var version: String

    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
}

public struct TetrisAIRequested: Codable, Equatable {
    public var streamObservations: Bool
    public var commandMode: TetrisAICommandMode
    public var role: TetrisAIRole?

    public init(streamObservations: Bool, commandMode: TetrisAICommandMode, role: TetrisAIRole? = nil) {
        self.streamObservations = streamObservations
        self.commandMode = commandMode
        self.role = role
    }

    private enum CodingKeys: String, CodingKey {
        case streamObservations = "stream_observations"
        case commandMode = "command_mode"
        case role
    }
}

public struct TetrisAIHello: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var client: TetrisAIClientInfo
    public var protocolVersion: String
    public var formats: [TetrisAIFormat]
    public var requested: TetrisAIRequested

    public init(
        seq: Int,
        tsMs: Int,
        client: TetrisAIClientInfo,
        protocolVersion: String,
        formats: [TetrisAIFormat],
        requested: TetrisAIRequested
    ) {
        self.type = "hello"
        self.seq = seq
        self.tsMs = tsMs
        self.client = client
        self.protocolVersion = protocolVersion
        self.formats = formats
        self.requested = requested
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case client
        case protocolVersion = "protocol_version"
        case formats
        case requested
    }
}

public struct TetrisAIWelcome: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var protocolVersion: String
    public var clientId: Int
    public var role: TetrisAIRole
    public var controllerId: Int?
    public var gameId: String
    public var capabilities: TetrisAICapabilities

    public init(
        seq: Int,
        tsMs: Int,
        protocolVersion: String,
        clientId: Int,
        role: TetrisAIRole,
        controllerId: Int? = nil,
        gameId: String,
        capabilities: TetrisAICapabilities
    ) {
        self.type = "welcome"
        self.seq = seq
        self.tsMs = tsMs
        self.protocolVersion = protocolVersion
        self.clientId = clientId
        self.role = role
        self.controllerId = controllerId
        self.gameId = gameId
        self.capabilities = capabilities
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case protocolVersion = "protocol_version"
        case clientId = "client_id"
        case role
        case controllerId = "controller_id"
        case gameId = "game_id"
        case capabilities
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(seq, forKey: .seq)
        try container.encode(tsMs, forKey: .tsMs)
        try container.encode(protocolVersion, forKey: .protocolVersion)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(role, forKey: .role)
        if let controllerId {
            try container.encode(controllerId, forKey: .controllerId)
        } else {
            try container.encodeNil(forKey: .controllerId)
        }
        try container.encode(gameId, forKey: .gameId)
        try container.encode(capabilities, forKey: .capabilities)
    }
}

public struct TetrisAICapabilities: Codable, Equatable, Sendable {
    public var formats: [TetrisAIFormat]
    public var commandModes: [TetrisAICommandMode]
    public var features: [String]
    public var featuresAlways: [String]
    public var featuresOptional: [String]
    public var controlPolicy: TetrisAIControlPolicy

    public init(
        formats: [TetrisAIFormat],
        commandModes: [TetrisAICommandMode],
        featuresAlways: [String],
        featuresOptional: [String],
        controlPolicy: TetrisAIControlPolicy
    ) {
        self.formats = formats
        self.commandModes = commandModes
        self.featuresAlways = featuresAlways
        self.featuresOptional = featuresOptional
        self.features = featuresAlways + featuresOptional
        self.controlPolicy = controlPolicy
    }

    public static let canonical = TetrisAICapabilities(
        formats: [.json],
        commandModes: [.action, .place],
        featuresAlways: [
            "next", "next_queue", "can_hold", "board_id", "events", "logical_step", "state_hash", "score", "timers",
        ],
        featuresOptional: ["hold", "ghost_y"],
        controlPolicy: .init(autoPromoteOnDisconnect: true, promotionOrder: "lowest_client_id")
    )

    private enum CodingKeys: String, CodingKey {
        case formats
        case commandModes = "command_modes"
        case features
        case featuresAlways = "features_always"
        case featuresOptional = "features_optional"
        case controlPolicy = "control_policy"
    }
}

public struct TetrisAIControlPolicy: Codable, Equatable, Sendable {
    public var autoPromoteOnDisconnect: Bool
    public var promotionOrder: String

    public init(autoPromoteOnDisconnect: Bool, promotionOrder: String) {
        self.autoPromoteOnDisconnect = autoPromoteOnDisconnect
        self.promotionOrder = promotionOrder
    }

    private enum CodingKeys: String, CodingKey {
        case autoPromoteOnDisconnect = "auto_promote_on_disconnect"
        case promotionOrder = "promotion_order"
    }
}

public struct TetrisAICommandEnvelope: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var mode: TetrisAICommandMode
    public var actions: [TetrisAIAction]?
    public var place: TetrisAIPlaceCommand?
    public var restart: TetrisAIRestartParameters?

    public init(
        seq: Int,
        tsMs: Int,
        mode: TetrisAICommandMode,
        actions: [TetrisAIAction]?,
        place: TetrisAIPlaceCommand?,
        restart: TetrisAIRestartParameters? = nil
    ) {
        self.type = "command"
        self.seq = seq
        self.tsMs = tsMs
        self.mode = mode
        self.actions = actions
        self.place = place
        self.restart = restart
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case mode
        case actions
        case place
        case restart
    }
}

public struct TetrisAIRestartParameters: Codable, Equatable {
    public var seed: UInt32

    public init(seed: UInt32) {
        self.seed = seed
    }
}

public struct TetrisAIControl: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var action: TetrisAIControlAction

    public init(seq: Int, tsMs: Int, action: TetrisAIControlAction) {
        self.type = "control"
        self.seq = seq
        self.tsMs = tsMs
        self.action = action
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case action
    }
}

public struct TetrisAIPlaceCommand: Codable, Equatable {
    public var x: Int
    public var rotation: TetrisAIRotation
    public var useHold: Bool

    public init(x: Int, rotation: TetrisAIRotation, useHold: Bool) {
        self.x = x
        self.rotation = rotation
        self.useHold = useHold
    }

    private enum CodingKeys: String, CodingKey {
        case x
        case rotation
        case useHold = "useHold"
    }
}

public struct TetrisAIObservationEnvelope: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var logicalStep: Int
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
    public var events: [TetrisAIEvent]
    public var stateHash: String
    public var score: Int
    public var level: Int
    public var lines: Int
    public var timers: TetrisAIObservationTimers

    public init(observation: TetrisAIObservation) {
        self.type = "observation"
        self.seq = observation.seq
        self.tsMs = observation.tsMs
        self.logicalStep = observation.logicalStep
        self.playable = observation.playable
        self.paused = observation.paused
        self.gameOver = observation.gameOver
        self.episodeId = observation.episodeId
        self.seed = observation.seed
        self.pieceId = observation.pieceId
        self.stepInPiece = observation.stepInPiece
        self.board = observation.board
        self.boardId = observation.boardId
        self.active = observation.active
        self.ghostY = observation.ghostY
        self.next = observation.next
        self.nextQueue = observation.nextQueue
        self.hold = observation.hold
        self.canHold = observation.canHold
        self.events = observation.events
        self.stateHash = observation.stateHash
        self.score = observation.score
        self.level = observation.level
        self.lines = observation.lines
        self.timers = observation.timers
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case logicalStep = "logical_step"
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
        case events
        case stateHash = "state_hash"
        case score
        case level
        case lines
        case timers
    }
}

public struct TetrisAIAck: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var status: String
    public var correlationSeq: Int
    public var appliedStep: Int?
    public var stateHash: String?

    public init(
        seq: Int,
        tsMs: Int,
        status: String,
        correlationSeq: Int,
        appliedStep: Int? = nil,
        stateHash: String? = nil
    ) {
        self.type = "ack"
        self.seq = seq
        self.tsMs = tsMs
        self.status = status
        self.correlationSeq = correlationSeq
        self.appliedStep = appliedStep
        self.stateHash = stateHash
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case status
        case correlationSeq = "correlation_seq"
        case appliedStep = "applied_step"
        case stateHash = "state_hash"
    }
}

public struct TetrisAIErrorMessage: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var code: String
    public var message: String
    public var retryAfterMs: Int?

    public init(seq: Int, tsMs: Int, code: String, message: String, retryAfterMs: Int? = nil) {
        self.type = "error"
        self.seq = seq
        self.tsMs = tsMs
        self.code = code
        self.message = message
        self.retryAfterMs = retryAfterMs
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case code
        case message
        case retryAfterMs = "retry_after_ms"
    }
}

public enum TetrisAIWireMessage: Equatable {
    case hello(TetrisAIHello)
    case welcome(TetrisAIWelcome)
    case command(TetrisAICommandEnvelope)
    case control(TetrisAIControl)
    case observation(TetrisAIObservation)
    case ack(TetrisAIAck)
    case error(TetrisAIErrorMessage)
}
