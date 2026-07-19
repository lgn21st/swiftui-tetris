import Foundation

final class AdapterWireLogger {
    private let queue = DispatchQueue(label: "adapter.socket.log")
    private let timeSource: () -> Int
    private var handle: FileHandle?

    init(path: String?, timeSource: @escaping () -> Int) {
        self.timeSource = timeSource
        guard let path else { return }
        let resolved = path == "auto" ? "/tmp/tetris-ai-adapter-\(timeSource()).jsonl" : path
        _ = FileManager.default.createFile(atPath: resolved, contents: nil)
        handle = FileHandle(forWritingAtPath: resolved)
    }

    func record(direction: String, connection: UUID, line: Data) {
        queue.async {
            guard let handle = self.handle else { return }
            var payload: [String: Any] = [
                "ts_ms": self.timeSource(),
                "direction": direction,
                "connection_id": connection.uuidString,
            ]
            if let text = String(data: line, encoding: .utf8) {
                payload["line"] = text
            } else {
                payload["line_base64"] = line.base64EncodedString()
            }
            guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return }
            handle.write(data)
            handle.write(Data([0x0A]))
        }
    }

    func close() {
        queue.sync {
            try? handle?.close()
            handle = nil
        }
    }
}
