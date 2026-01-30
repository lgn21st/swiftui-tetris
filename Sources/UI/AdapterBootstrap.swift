import Foundation
import Adapter

public enum AdapterBootstrap {
    public static func fromEnvironment() -> AdapterHandling? {
        let env = ProcessInfo.processInfo.environment
        guard let config = configuration(from: env) else { return nil }
        return SocketAdapter(configuration: config)
    }

    internal static func configuration(from env: [String: String]) -> SocketAdapterConfiguration? {
        guard let transportValue = env["TETRIS_AI_TRANSPORT"]?.lowercased() else {
            return nil
        }

        let transport: SocketTransportConfiguration
        switch transportValue {
        case "unix":
            let path = env["TETRIS_AI_UNIX_PATH"] ?? "/tmp/tetris-ai.sock"
            transport = .unix(path: path)
        case "tcp":
            let host = env["TETRIS_AI_HOST"] ?? "127.0.0.1"
            let port = Int(env["TETRIS_AI_PORT"] ?? "") ?? 7777
            transport = .tcp(host: host, port: port)
        default:
            return nil
        }

        var config = SocketAdapterConfiguration(transport: transport)
        if let value = env["TETRIS_AI_IDLE_TIMEOUT_MS"], let parsed = Int(value) {
            config.idleTimeoutMs = parsed > 0 ? parsed : nil
        }
        if let value = env["TETRIS_AI_MAX_PENDING"], let parsed = Int(value), parsed > 0 {
            config.maxPendingCommands = parsed
        }
        if let value = env["TETRIS_AI_OBSERVATION_MS"], let parsed = Int(value), parsed >= 0 {
            config.observationIntervalMs = parsed
        }
        return config
    }
}
