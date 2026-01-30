import Foundation
import Adapter

public enum AdapterBootstrap {
    public static func fromEnvironment() -> AdapterHandling? {
        let env = ProcessInfo.processInfo.environment
        guard let transportValue = env["TETRIS_AI_TRANSPORT"]?.lowercased() else {
            return nil
        }

        switch transportValue {
        case "unix":
            let path = env["TETRIS_AI_UNIX_PATH"] ?? "/tmp/tetris-ai.sock"
            let config = SocketAdapterConfiguration(transport: .unix(path: path))
            return SocketAdapter(configuration: config)
        case "tcp":
            let host = env["TETRIS_AI_HOST"] ?? "127.0.0.1"
            let port = Int(env["TETRIS_AI_PORT"] ?? "") ?? 7777
            let config = SocketAdapterConfiguration(transport: .tcp(host: host, port: port))
            return SocketAdapter(configuration: config)
        default:
            return nil
        }
    }
}
