import Foundation
import Core

public enum TetrisAIFormat: String, Codable, Equatable {
    case json
    case msgpack
    case protobuf
}

public enum TetrisAICommandMode: String, Codable, Equatable {
    case action
    case place
}

public enum TetrisAIControlAction: String, Codable, Equatable {
    case claim
    case release
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

    public init(streamObservations: Bool, commandMode: TetrisAICommandMode) {
        self.streamObservations = streamObservations
        self.commandMode = commandMode
    }

    private enum CodingKeys: String, CodingKey {
        case streamObservations = "stream_observations"
        case commandMode = "command_mode"
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
    public var gameId: String
    public var capabilities: TetrisAICapabilities

    public init(
        seq: Int,
        tsMs: Int,
        protocolVersion: String,
        gameId: String,
        capabilities: TetrisAICapabilities
    ) {
        self.type = "welcome"
        self.seq = seq
        self.tsMs = tsMs
        self.protocolVersion = protocolVersion
        self.gameId = gameId
        self.capabilities = capabilities
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case protocolVersion = "protocol_version"
        case gameId = "game_id"
        case capabilities
    }
}

public struct TetrisAICapabilities: Codable, Equatable {
    public var formats: [TetrisAIFormat]
    public var commandModes: [TetrisAICommandMode]
    public var features: [String]

    public init(formats: [TetrisAIFormat], commandModes: [TetrisAICommandMode], features: [String]) {
        self.formats = formats
        self.commandModes = commandModes
        self.features = features
    }

    private enum CodingKeys: String, CodingKey {
        case formats
        case commandModes = "command_modes"
        case features
    }
}

public struct TetrisAICommandEnvelope: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var mode: TetrisAICommandMode
    public var actions: [TetrisAIAction]?
    public var place: TetrisAIPlaceCommand?

    public init(
        seq: Int,
        tsMs: Int,
        mode: TetrisAICommandMode,
        actions: [TetrisAIAction]?,
        place: TetrisAIPlaceCommand?
    ) {
        self.type = "command"
        self.seq = seq
        self.tsMs = tsMs
        self.mode = mode
        self.actions = actions
        self.place = place
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case mode
        case actions
        case place
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
    public var playable: Bool
    public var paused: Bool
    public var gameOver: Bool
    public var episodeId: Int
    public var seed: UInt64
    public var pieceId: Int
    public var stepInPiece: Int
    public var board: TetrisAIObservationBoard
    public var active: TetrisAIObservationActive?
    public var next: TetrisAIPieceKind?
    public var nextQueue: [TetrisAIPieceKind]
    public var hold: TetrisAIPieceKind?
    public var canHold: Bool
    public var lastEvent: TetrisAILastEvent
    public var stateHash: String
    public var score: Int
    public var level: Int
    public var lines: Int
    public var timers: TetrisAIObservationTimers

    public init(observation: TetrisAIObservation) {
        self.type = "observation"
        self.seq = observation.seq
        self.tsMs = observation.tsMs
        self.playable = observation.playable
        self.paused = observation.paused
        self.gameOver = observation.gameOver
        self.episodeId = observation.episodeId
        self.seed = observation.seed
        self.pieceId = observation.pieceId
        self.stepInPiece = observation.stepInPiece
        self.board = observation.board
        self.active = observation.active
        self.next = observation.next
        self.nextQueue = observation.nextQueue
        self.hold = observation.hold
        self.canHold = observation.canHold
        self.lastEvent = observation.lastEvent
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
        case playable
        case paused
        case gameOver = "game_over"
        case episodeId = "episode_id"
        case seed
        case pieceId = "piece_id"
        case stepInPiece = "step_in_piece"
        case board
        case active
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

public struct TetrisAIAck: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var status: String

    public init(seq: Int, tsMs: Int, status: String) {
        self.type = "ack"
        self.seq = seq
        self.tsMs = tsMs
        self.status = status
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case status
    }
}

public struct TetrisAIErrorMessage: Codable, Equatable {
    public let type: String
    public var seq: Int
    public var tsMs: Int
    public var code: String
    public var message: String

    public init(seq: Int, tsMs: Int, code: String, message: String) {
        self.type = "error"
        self.seq = seq
        self.tsMs = tsMs
        self.code = code
        self.message = message
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case seq
        case tsMs = "ts"
        case code
        case message
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
