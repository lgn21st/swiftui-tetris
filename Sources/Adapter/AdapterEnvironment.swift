import Foundation

public enum AdapterEnvironment {
    public static func configuration(
        from environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> SocketAdapterConfiguration? {
        if ["1", "true"].contains(environment["TETRIS_AI_DISABLED"]?.lowercased()) {
            return nil
        }

        let host = environment["TETRIS_AI_HOST"] ?? "127.0.0.1"
        let port = environment["TETRIS_AI_PORT"]
            .flatMap(Int.init)
            .flatMap { (0...65_535).contains($0) ? $0 : nil } ?? 7777
        var configuration = SocketAdapterConfiguration(transport: .tcp(host: host, port: port))

        if let raw = environment["TETRIS_AI_IDLE_TIMEOUT_MS"], let value = Int(raw) {
            configuration.idleTimeoutMs = value > 0 ? value : nil
        }
        if let value = positiveInt("TETRIS_AI_MAX_PENDING", in: environment) {
            configuration.maxPendingCommands = value
        }
        if let value = positiveInt("TETRIS_AI_MAX_OUTBOUND_BYTES", in: environment) {
            configuration.maxOutboundBytes = value
        }
        if let value = positiveInt("TETRIS_AI_BACKPRESSURE_RETRY_MS", in: environment) {
            configuration.backpressureRetryAfterMs = value
        }
        if let raw = environment["TETRIS_AI_OBSERVATION_MS"], let value = Int(raw), value >= 0 {
            configuration.observationIntervalMs = value
        }
        let logPath = environment["TETRIS_AI_LOG_PATH"] ?? "auto"
        if !logPath.isEmpty {
            configuration.logPath = logPath
        }
        return configuration
    }

    private static func positiveInt(_ key: String, in environment: [String: String]) -> Int? {
        guard let raw = environment[key], let value = Int(raw), value > 0 else { return nil }
        return value
    }
}
