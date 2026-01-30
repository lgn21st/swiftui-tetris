import Foundation
import Core

public struct SocketAdapterConfiguration: Equatable {
    public var transport: SocketTransportConfiguration
    public var protocolVersion: String
    public var gameId: String
    public var supportedFormats: [TetrisAIFormat]
    public var supportedCommandModes: [TetrisAICommandMode]
    public var features: [String]

    public init(
        transport: SocketTransportConfiguration,
        protocolVersion: String = "1.0.0",
        gameId: String = "swiftui-spritekit-tetris",
        supportedFormats: [TetrisAIFormat] = [.json],
        supportedCommandModes: [TetrisAICommandMode] = [.action, .place],
        features: [String] = ["hold", "next", "score", "timers"]
    ) {
        self.transport = transport
        self.protocolVersion = protocolVersion
        self.gameId = gameId
        self.supportedFormats = supportedFormats
        self.supportedCommandModes = supportedCommandModes
        self.features = features
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
    private var handshakeComplete = false

    public init(
        configuration: SocketAdapterConfiguration,
        timeSource: @escaping () -> Int = SocketAdapter.defaultTimeSource
    ) {
        self.configuration = configuration
        self.transport = SocketServerTransport(configuration: configuration.transport)
        self.timeSource = timeSource
        self.seq = 0
        self.transport.onReceive = { [weak self] data in
            self?.handleIncoming(data: data)
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
        guard handshakeComplete else { return }
        seq += 1
        let observation = ObservationMapper.map(snapshot: snapshot, seq: seq, tsMs: timeSource())
        if let data = try? WireCodec.encode(.observation(observation)) {
            transport.send(line: data)
        }
    }

    private func handleIncoming(data: Data) {
        guard let message = try? WireCodec.decode(data) else { return }
        switch message {
        case .hello(let hello):
            handleHello(hello)
        case .command(let command):
            handleCommand(command)
        default:
            break
        }
    }

    private func handleHello(_ hello: TetrisAIHello) {
        handshakeComplete = true
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
            transport.send(line: data)
        }
    }

    private func handleCommand(_ command: TetrisAICommandEnvelope) {
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

        guard let parsed else { return }
        queue.sync {
            pendingCommands.append(parsed)
        }
    }

    public static func defaultTimeSource() -> Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }
}
