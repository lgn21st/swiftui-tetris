import Foundation

enum WireCodecError: Error {
    case unknownType
    case invalidData
}

enum WireCodec {
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()

    static func encode(_ message: TetrisAIWireMessage) throws -> Data {
        switch message {
        case .hello(let hello):
            return try encoder.encode(hello)
        case .welcome(let welcome):
            return try encoder.encode(welcome)
        case .command(let command):
            return try encoder.encode(command)
        case .control(let control):
            return try encoder.encode(control)
        case .observation(let observation):
            return try encoder.encode(TetrisAIObservationEnvelope(observation: observation))
        case .ack(let ack):
            return try encoder.encode(ack)
        case .error(let error):
            return try encoder.encode(error)
        }
    }

    static func decode(_ data: Data) throws -> TetrisAIWireMessage {
        struct Envelope: Decodable {
            let type: String
        }

        guard !data.isEmpty else { throw WireCodecError.invalidData }
        let envelope = try decoder.decode(Envelope.self, from: data)

        switch envelope.type {
        case "hello":
            return .hello(try decoder.decode(TetrisAIHello.self, from: data))
        case "welcome":
            return .welcome(try decoder.decode(TetrisAIWelcome.self, from: data))
        case "command":
            return .command(try decoder.decode(TetrisAICommandEnvelope.self, from: data))
        case "control":
            return .control(try decoder.decode(TetrisAIControl.self, from: data))
        case "observation":
            let obs = try decoder.decode(TetrisAIObservationEnvelope.self, from: data)
            return .observation(
                TetrisAIObservation(
                    seq: obs.seq,
                    tsMs: obs.tsMs,
                    playable: obs.playable,
                    paused: obs.paused,
                    gameOver: obs.gameOver,
                    episodeId: obs.episodeId,
                    seed: obs.seed,
                    pieceId: obs.pieceId,
                    stepInPiece: obs.stepInPiece,
                    board: obs.board,
                    boardId: obs.boardId,
                    active: obs.active,
                    ghostY: obs.ghostY,
                    next: obs.next,
                    nextQueue: obs.nextQueue,
                    hold: obs.hold,
                    canHold: obs.canHold,
                    lastEvent: obs.lastEvent,
                    stateHash: obs.stateHash,
                    score: obs.score,
                    level: obs.level,
                    lines: obs.lines,
                    timers: obs.timers
                )
            )
        case "ack":
            return .ack(try decoder.decode(TetrisAIAck.self, from: data))
        case "error":
            return .error(try decoder.decode(TetrisAIErrorMessage.self, from: data))
        default:
            throw WireCodecError.unknownType
        }
    }
}
