import Foundation
import Core

public struct SocketAdapterConfiguration: Equatable {
    public var transport: SocketTransportConfiguration
    public var protocolVersion: String
    public var gameId: String
    public var supportedFormats: [TetrisAIFormat]
    public var supportedCommandModes: [TetrisAICommandMode]
    public var features: [String]
    public var idleTimeoutMs: Int?

    public init(
        transport: SocketTransportConfiguration,
        protocolVersion: String = "1.0.0",
        gameId: String = "swiftui-spritekit-tetris",
        supportedFormats: [TetrisAIFormat] = [.json],
        supportedCommandModes: [TetrisAICommandMode] = [.action, .place],
        features: [String] = ["hold", "next", "score", "timers"],
        idleTimeoutMs: Int? = 2000
    ) {
        self.transport = transport
        self.protocolVersion = protocolVersion
        self.gameId = gameId
        self.supportedFormats = supportedFormats
        self.supportedCommandModes = supportedCommandModes
        self.features = features
        self.idleTimeoutMs = idleTimeoutMs
    }
}

public protocol AdapterLifecycle {
    func start()
    func stop()
}

public final class SocketAdapter: AdapterHandling, AdapterLifecycle {
    private let configuration: SocketAdapterConfiguration
    private let transport: SocketServerTransport
    private let timeSource: () -> Int
    private var seq: Int
    private let queue = DispatchQueue(label: "adapter.socket.state")
    private var pendingCommands: [TetrisAICommand] = []
    private var clients: [UUID: ClientState] = [:]
    private var controllerId: UUID?

    public var boundPort: Int? { transport.boundPort }
    public var boundPath: String? { transport.boundPath }

    public init(
        configuration: SocketAdapterConfiguration,
        timeSource: @escaping () -> Int = SocketAdapter.defaultTimeSource
    ) {
        self.configuration = configuration
        self.transport = SocketServerTransport(
            configuration: configuration.transport,
            idleTimeoutMs: configuration.idleTimeoutMs
        )
        self.timeSource = timeSource
        self.seq = 0
        self.transport.onReceive = { [weak self] connectionId, data in
            self?.handleIncoming(connectionId: connectionId, data: data)
        }
        self.transport.onDisconnect = { [weak self] connectionId in
            self?.handleDisconnect(connectionId: connectionId)
        }
        start()
    }

    public func start() {
        try? transport.start()
    }

    public func stop() {
        transport.stop()
    }

    public func poll(elapsedMs: Int, state: inout GameState) {
        let commands = queue.sync { () -> [TetrisAICommand] in
            let drained = pendingCommands
            pendingCommands = []
            return drained
        }

        for command in commands {
            let snapshot = state.snapshot()
            if let actions = try? CommandMapper.map(command: command, snapshot: snapshot) {
                for action in actions {
                    state.apply(action: action)
                }
            }
        }
    }

    public func emit(snapshot: GameStateSnapshot) {
        let targets = queue.sync { () -> [UUID] in
            clients
                .filter { $0.value.handshakeComplete && $0.value.streamObservations }
                .map { $0.key }
        }
        guard !targets.isEmpty else { return }
        seq += 1
        let observation = ObservationMapper.map(snapshot: snapshot, seq: seq, tsMs: timeSource())
        if let data = try? WireCodec.encode(.observation(observation)) {
            transport.broadcast(line: data, to: targets)
        }
    }

    private func handleIncoming(connectionId: UUID, data: Data) {
        guard let message = try? WireCodec.decode(data) else { return }
        switch message {
        case .hello(let hello):
            handleHello(connectionId: connectionId, hello: hello)
        case .command(let command):
            handleCommand(connectionId: connectionId, command: command)
        default:
            break
        }
    }

    private func handleHello(connectionId: UUID, hello: TetrisAIHello) {
        guard compatibleMajorVersion(server: configuration.protocolVersion, client: hello.protocolVersion) else {
            sendError(connectionId: connectionId, seq: hello.seq, code: "protocol_mismatch", message: "Incompatible protocol version.")
            return
        }
        _ = queue.sync { () -> ClientRole in
            let assignedRole: ClientRole
            if controllerId == nil {
                controllerId = connectionId
                assignedRole = .controller
            } else {
                assignedRole = .observer
            }
            clients[connectionId] = ClientState(
                handshakeComplete: true,
                streamObservations: hello.requested.streamObservations,
                role: assignedRole
            )
            return assignedRole
        }
        let welcome = TetrisAIWelcome(
            seq: hello.seq,
            tsMs: timeSource(),
            protocolVersion: configuration.protocolVersion,
            gameId: configuration.gameId,
            capabilities: TetrisAICapabilities(
                formats: configuration.supportedFormats,
                commandModes: configuration.supportedCommandModes,
                features: configuration.features
            )
        )
        if let data = try? WireCodec.encode(.welcome(welcome)) {
            transport.send(line: data, to: connectionId)
        }
    }

    private func handleCommand(connectionId: UUID, command: TetrisAICommandEnvelope) {
        guard isHandshakeComplete(connectionId: connectionId) else {
            sendError(connectionId: connectionId, seq: command.seq, code: "handshake_required", message: "Send hello before commands.")
            return
        }
        guard isController(connectionId: connectionId) else {
            sendError(connectionId: connectionId, seq: command.seq, code: "not_controller", message: "Only controller may send commands.")
            return
        }
        let parsed: TetrisAICommand?
        switch command.mode {
        case .action:
            if let actions = command.actions {
                parsed = .action(actions: actions)
            } else {
                parsed = nil
            }
        case .place:
            if let place = command.place {
                parsed = .place(x: place.x, rotation: place.rotation, useHold: place.useHold)
            } else {
                parsed = nil
            }
        }

        guard let parsed else {
            sendError(connectionId: connectionId, seq: command.seq, code: "invalid_command", message: "Missing command payload.")
            return
        }
        queue.sync {
            pendingCommands.append(parsed)
        }
        sendAck(connectionId: connectionId, seq: command.seq, status: "ok")
    }

    public static func defaultTimeSource() -> Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }

    private func sendAck(connectionId: UUID, seq: Int, status: String) {
        let ack = TetrisAIAck(seq: seq, tsMs: timeSource(), status: status)
        if let data = try? WireCodec.encode(.ack(ack)) {
            transport.send(line: data, to: connectionId)
        }
    }

    private func sendError(connectionId: UUID, seq: Int, code: String, message: String) {
        let error = TetrisAIErrorMessage(seq: seq, tsMs: timeSource(), code: code, message: message)
        if let data = try? WireCodec.encode(.error(error)) {
            transport.send(line: data, to: connectionId)
        }
    }

    private func compatibleMajorVersion(server: String, client: String) -> Bool {
        func major(_ version: String) -> Int? {
            Int(version.split(separator: ".").first ?? "")
        }
        guard let serverMajor = major(server), let clientMajor = major(client) else { return false }
        return serverMajor == clientMajor
    }

    private func isHandshakeComplete(connectionId: UUID) -> Bool {
        queue.sync {
            clients[connectionId]?.handshakeComplete ?? false
        }
    }

    private func isController(connectionId: UUID) -> Bool {
        queue.sync {
            controllerId == connectionId
        }
    }

    private func handleDisconnect(connectionId: UUID) {
        queue.sync {
            clients.removeValue(forKey: connectionId)
            if controllerId == connectionId {
                controllerId = nil
            }
        }
    }
}

private struct ClientState {
    var handshakeComplete: Bool
    var streamObservations: Bool
    var role: ClientRole
}

private enum ClientRole {
    case controller
    case observer
}
