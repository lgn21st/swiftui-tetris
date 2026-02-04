import Foundation
import Adapter

public enum AdapterBootstrap {
    public static func fromEnvironment() -> AdapterHandling? {
        let env = ProcessInfo.processInfo.environment
        guard let config = configuration(from: env) else { return nil }
        return SocketAdapter(configuration: config)
    }

    internal static func configuration(from env: [String: String]) -> SocketAdapterConfiguration? {
        if env["TETRIS_AI_DISABLED"] == "1" {
            return nil
        }

        // Protocol standard: only supported transport is TCP localhost on the default port.
        let transport: SocketTransportConfiguration = .tcp(host: "127.0.0.1", port: 7777)

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
        let logPath = env["TETRIS_AI_LOG_PATH"] ?? "auto"
        if !logPath.isEmpty {
            config.logPath = logPath
        }
        return config
    }
}
