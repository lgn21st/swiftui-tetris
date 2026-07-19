import Foundation
import Core

public struct SocketAdapterConfiguration: Equatable {
    public var transport: SocketTransportConfiguration
    public var protocolVersion: String
    public var gameId: String
    public var supportedFormats: [TetrisAIFormat]
    public var supportedCommandModes: [TetrisAICommandMode]
    public var featuresAlways: [String]
    public var featuresOptional: [String]
    public var controlPolicy: TetrisAIControlPolicy
    public var idleTimeoutMs: Int?
    public var maxPendingCommands: Int
    public var maxOutboundBytes: Int
    public var backpressureRetryAfterMs: Int
    public var observationIntervalMs: Int?
    public var logPath: String?

    public init(
        transport: SocketTransportConfiguration,
        protocolVersion: String = "3.0.0",
        gameId: String = "swiftui-spritekit-tetris",
        supportedFormats: [TetrisAIFormat] = [.json],
        supportedCommandModes: [TetrisAICommandMode] = [.action, .place],
        featuresAlways: [String] = [
            "next",
            "next_queue",
            "can_hold",
            "board_id",
            "events",
            "logical_step",
            "state_hash",
            "score",
            "timers",
        ],
        featuresOptional: [String] = ["hold", "ghost_y"],
        controlPolicy: TetrisAIControlPolicy = .init(
            autoPromoteOnDisconnect: true,
            promotionOrder: "lowest_client_id"
        ),
        idleTimeoutMs: Int? = 2000,
        maxPendingCommands: Int = 64,
        maxOutboundBytes: Int = 262_144,
        backpressureRetryAfterMs: Int = 50,
        observationIntervalMs: Int? = nil,
        logPath: String? = nil
    ) {
        self.transport = transport
        self.protocolVersion = protocolVersion
        self.gameId = gameId
        self.supportedFormats = supportedFormats
        self.supportedCommandModes = supportedCommandModes
        self.featuresAlways = featuresAlways
        self.featuresOptional = featuresOptional
        self.controlPolicy = controlPolicy
        self.idleTimeoutMs = idleTimeoutMs
        self.maxPendingCommands = maxPendingCommands
        self.maxOutboundBytes = maxOutboundBytes
        self.backpressureRetryAfterMs = backpressureRetryAfterMs
        self.observationIntervalMs = observationIntervalMs
        self.logPath = logPath
    }
}

public protocol AdapterLifecycle {
    func start()
    func stop()
}

public final class SocketAdapter: AdapterHandling, AdapterLifecycle {
    private struct PendingCommand {
        let connectionId: UUID
        let seq: Int
        let command: TetrisAICommand
        let restartSeed: UInt32?
    }

    private let configuration: SocketAdapterConfiguration
    private let transport: SocketServerTransport
    private let timeSource: () -> Int
    private var seq: Int
    private let queue = DispatchQueue(label: "adapter.socket.state")
    private let logger: AdapterWireLogger
    private var pendingCommands: [PendingCommand] = []
    private var sessions = AdapterSessionRegistry()
    private var lastObservationTs: Int?
    private var latestSnapshot: GameStateSnapshot?

    public var boundPort: Int? { transport.boundPort }
    
    public init(
        configuration: SocketAdapterConfiguration,
        timeSource: @escaping () -> Int = SocketAdapter.defaultTimeSource
    ) {
        self.configuration = configuration
        self.transport = SocketServerTransport(
            configuration: configuration.transport,
            idleTimeoutMs: configuration.idleTimeoutMs,
            maxQueuedBytes: configuration.maxOutboundBytes
        )
        self.timeSource = timeSource
        self.seq = 0
        self.logger = AdapterWireLogger(path: configuration.logPath, timeSource: timeSource)
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
        logger.close()
    }

    public func poll(elapsedMs: Int, state: inout GameState) {
        let commands = queue.sync { () -> [PendingCommand] in
            let drained = pendingCommands
            pendingCommands = []
            return drained
        }

        for pending in commands {
            do {
                let appliedSnapshot = try AdapterCommandExecutor.execute(
                    pending.command,
                    restartSeed: pending.restartSeed,
                    state: &state
                )
                sendAck(
                    connectionId: pending.connectionId,
                    seq: pending.seq,
                    status: "ok",
                    appliedStep: appliedSnapshot.logicalStep,
                    stateHash: ObservationMapper.stateHash(appliedSnapshot)
                )
            } catch let error as CommandMappingError {
                let mapped = mapCommandError(error)
                sendError(connectionId: pending.connectionId, seq: pending.seq, code: mapped.code, message: mapped.message)
            } catch {
                sendError(connectionId: pending.connectionId, seq: pending.seq, code: "invalid_command", message: "Failed to map command.")
            }
        }
    }

    public func emit(snapshot: GameStateSnapshot) {
        let now = timeSource()
        let emission = queue.sync { () -> (targets: [UUID], seq: Int)? in
            latestSnapshot = snapshot
            let targets = sessions.observationTargets
            guard !targets.isEmpty else { return nil }
            if let interval = configuration.observationIntervalMs, interval > 0,
               let lastObservationTs, now - lastObservationTs < interval {
                return nil
            }
            seq += 1
            lastObservationTs = now
            return (targets, seq)
        }
        guard let emission else { return }
        let observation = ObservationMapper.map(snapshot: snapshot, seq: emission.seq, tsMs: now)
        if let data = try? WireCodec.encode(.observation(observation)) {
            broadcastLine(line: data, to: emission.targets, delivery: .latestObservation)
        }
    }

    private func handleIncoming(connectionId: UUID, data: Data) {
        logEvent(direction: "recv", connectionId: connectionId, line: data)
        let message: TetrisAIWireMessage
        do {
            message = try WireCodec.decode(data)
        } catch {
            sendError(
                connectionId: connectionId,
                seq: bestEffortSeq(from: data),
                code: "invalid_command",
                message: "Invalid JSON or missing required fields."
            )
            return
        }
        switch message {
        case .hello(let hello):
            handleHello(connectionId: connectionId, hello: hello)
        case .command(let command):
            handleCommand(connectionId: connectionId, command: command)
        case .control(let control):
            handleControl(connectionId: connectionId, control: control)
        default:
            break
        }
    }

    private func bestEffortSeq(from data: Data) -> Int {
        guard
            let object = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = object as? [String: Any]
        else { return 0 }
        if let seq = dict["seq"] as? Int {
            return seq
        }
        if let seq = dict["seq"] as? NSNumber {
            return seq.intValue
        }
        return 0
    }

    private func handleHello(connectionId: UUID, hello: TetrisAIHello) {
        guard !isHandshakeComplete(connectionId: connectionId) else {
            sendError(connectionId: connectionId, seq: hello.seq, code: "invalid_command", message: "Handshake already completed.")
            return
        }
        guard hello.seq == 1 else {
            sendError(connectionId: connectionId, seq: hello.seq, code: "invalid_command", message: "hello.seq must be 1.")
            return
        }
        guard compatibleMajorVersion(server: configuration.protocolVersion, client: hello.protocolVersion) else {
            sendError(connectionId: connectionId, seq: hello.seq, code: "protocol_mismatch", message: "Incompatible protocol version.")
            return
        }
        guard hello.formats.contains(.json) else {
            sendError(connectionId: connectionId, seq: hello.seq, code: "protocol_mismatch", message: "JSON format is required.")
            return
        }
        guard configuration.supportedCommandModes.contains(hello.requested.commandMode) else {
            sendError(connectionId: connectionId, seq: hello.seq, code: "protocol_mismatch", message: "Unsupported command mode.")
            return
        }

        let assigned = queue.sync {
            sessions.register(
                connectionId,
                requestedRole: hello.requested.role ?? .auto,
                streamsObservations: hello.requested.streamObservations
            )
        }
        let welcome = TetrisAIWelcome(
            seq: hello.seq,
            tsMs: timeSource(),
            protocolVersion: configuration.protocolVersion,
            clientId: assigned.clientId,
            role: assigned.role,
            controllerId: assigned.controllerClientId,
            gameId: configuration.gameId,
            capabilities: TetrisAICapabilities(
                formats: configuration.supportedFormats,
                commandModes: configuration.supportedCommandModes,
                featuresAlways: configuration.featuresAlways,
                featuresOptional: configuration.featuresOptional,
                controlPolicy: configuration.controlPolicy
            )
        )
        if let data = try? WireCodec.encode(.welcome(welcome)) {
            sendLine(line: data, to: connectionId)
        }
        if hello.requested.streamObservations {
            sendLatestObservation(to: connectionId)
        }
    }

    private func handleCommand(connectionId: UUID, command: TetrisAICommandEnvelope) {
        guard isHandshakeComplete(connectionId: connectionId) else {
            sendError(connectionId: connectionId, seq: command.seq, code: "handshake_required", message: "Send hello before commands.")
            return
        }
        guard validateAndUpdateSeq(connectionId: connectionId, seq: command.seq) else {
            sendError(connectionId: connectionId, seq: command.seq, code: "invalid_command", message: "seq must be strictly increasing.")
            return
        }
        guard isController(connectionId: connectionId) else {
            sendError(connectionId: connectionId, seq: command.seq, code: "not_controller", message: "Only controller may send commands.")
            return
        }
        let parsed: TetrisAICommand?
        switch command.mode {
        case .action:
            if let actions = command.actions, actions.count <= 32 {
                guard command.restart == nil || actions.contains(.restart) else {
                    sendError(connectionId: connectionId, seq: command.seq, code: "invalid_command", message: "restart parameters require a restart action.")
                    return
                }
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
        let enqueued = queue.sync { () -> Bool in
            guard pendingCommands.count < configuration.maxPendingCommands else { return false }
            pendingCommands.append(PendingCommand(
                connectionId: connectionId,
                seq: command.seq,
                command: parsed,
                restartSeed: command.restart?.seed
            ))
            return true
        }
        if !enqueued {
            sendError(
                connectionId: connectionId,
                seq: command.seq,
                code: "backpressure",
                message: "Command queue full.",
                retryAfterMs: configuration.backpressureRetryAfterMs
            )
        }
    }

    private func handleControl(connectionId: UUID, control: TetrisAIControl) {
        guard isHandshakeComplete(connectionId: connectionId) else {
            sendError(connectionId: connectionId, seq: control.seq, code: "handshake_required", message: "Send hello before control.")
            return
        }
        guard validateAndUpdateSeq(connectionId: connectionId, seq: control.seq) else {
            sendError(connectionId: connectionId, seq: control.seq, code: "invalid_command", message: "seq must be strictly increasing.")
            return
        }
        switch control.action {
        case .claim:
            let claimResult = queue.sync { sessions.claim(connectionId) }
            if claimResult {
                sendAck(connectionId: connectionId, seq: control.seq, status: "ok")
            } else {
                sendError(connectionId: connectionId, seq: control.seq, code: "controller_active", message: "Controller already assigned.")
            }
        case .release:
            let released = queue.sync { sessions.release(connectionId) }
            if released {
                sendAck(connectionId: connectionId, seq: control.seq, status: "ok")
            } else {
                sendError(connectionId: connectionId, seq: control.seq, code: "not_controller", message: "Only controller may release control.")
            }
        }
    }

    public static func defaultTimeSource() -> Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }

    private func sendAck(
        connectionId: UUID,
        seq: Int,
        status: String,
        appliedStep: Int? = nil,
        stateHash: String? = nil
    ) {
        let ack = TetrisAIAck(
            seq: seq,
            tsMs: timeSource(),
            status: status,
            correlationSeq: seq,
            appliedStep: appliedStep,
            stateHash: stateHash
        )
        if let data = try? WireCodec.encode(.ack(ack)) {
            sendLine(line: data, to: connectionId)
        }
    }

    private func sendError(
        connectionId: UUID,
        seq: Int,
        code: String,
        message: String,
        retryAfterMs: Int? = nil
    ) {
        let error = TetrisAIErrorMessage(
            seq: seq,
            tsMs: timeSource(),
            code: code,
            message: message,
            retryAfterMs: retryAfterMs
        )
        if let data = try? WireCodec.encode(.error(error)) {
            sendLine(line: data, to: connectionId)
        }
    }

    private func sendLine(
        line: Data,
        to connectionId: UUID,
        delivery: SocketOutboundDelivery = .required
    ) {
        logEvent(direction: "send", connectionId: connectionId, line: line)
        transport.send(line: line, to: connectionId, delivery: delivery)
    }

    private func broadcastLine(
        line: Data,
        to connectionIds: [UUID],
        delivery: SocketOutboundDelivery = .required
    ) {
        for connectionId in connectionIds {
            sendLine(line: line, to: connectionId, delivery: delivery)
        }
    }

    private func logEvent(direction: String, connectionId: UUID, line: Data) {
        logger.record(direction: direction, connection: connectionId, line: line)
    }

    private func mapCommandError(_ error: CommandMappingError) -> (code: String, message: String) {
        switch error {
        case .unsupportedMode:
            return ("invalid_command", "Unsupported command mode.")
        case .snapshotRequired:
            return ("snapshot_required", "Snapshot required for command.")
        case .holdUnavailable:
            return ("hold_unavailable", "Hold unavailable.")
        case .invalidPlace:
            return ("invalid_place", "Invalid place command.")
        }
    }

    private func compatibleMajorVersion(server: String, client: String) -> Bool {
        guard let serverMajor = SemanticVersion.major(server), let clientMajor = SemanticVersion.major(client) else { return false }
        return serverMajor == clientMajor
    }

    private func sendLatestObservation(to connectionId: UUID) {
        let payload = queue.sync { () -> (GameStateSnapshot, Int)? in
            guard let latestSnapshot else { return nil }
            seq += 1
            return (latestSnapshot, seq)
        }
        guard let (snapshot, observationSeq) = payload else { return }
        let observation = ObservationMapper.map(snapshot: snapshot, seq: observationSeq, tsMs: timeSource())
        if let data = try? WireCodec.encode(.observation(observation)) {
            sendLine(line: data, to: connectionId, delivery: .latestObservation)
        }
    }

    private func isHandshakeComplete(connectionId: UUID) -> Bool {
        queue.sync { sessions.contains(connectionId) }
    }

    private func validateAndUpdateSeq(connectionId: UUID, seq: Int) -> Bool {
        queue.sync { sessions.accept(sequence: seq, from: connectionId) }
    }

    private func isController(connectionId: UUID) -> Bool {
        queue.sync { sessions.isController(connectionId) }
    }

    private func handleDisconnect(connectionId: UUID) {
        queue.sync { sessions.disconnect(connectionId) }
    }
}

private enum SemanticVersion {
    private static let expression = try! NSRegularExpression(
        pattern: #"^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-((?:0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$"#
    )

    static func major(_ value: String) -> Int? {
        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        guard let match = expression.firstMatch(in: value, range: range), match.range == range,
              let majorRange = Range(match.range(at: 1), in: value) else { return nil }
        return Int(value[majorRange])
    }
}
