import Foundation
import Testing
@testable import Adapter

@Suite struct AdapterWireLoggerTests {
    @Test func writesOneStructuredJsonLine() throws {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("adapter-wire-\(UUID().uuidString).jsonl")
            .path
        defer { try? FileManager.default.removeItem(atPath: path) }
        let connection = UUID()
        let logger = AdapterWireLogger(path: path, timeSource: { 123 })

        logger.record(direction: "recv", connection: connection, line: Data(#"{"type":"hello"}"#.utf8))
        logger.close()

        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let line = try #require(data.split(separator: 0x0A).first)
        let object = try #require(JSONSerialization.jsonObject(with: Data(line)) as? [String: Any])
        #expect(object["ts_ms"] as? Int == 123)
        #expect(object["direction"] as? String == "recv")
        #expect(object["connection_id"] as? String == connection.uuidString)
        #expect(object["line"] as? String == #"{"type":"hello"}"#)
    }

    @Test func dropsBestEffortRecordsWhenCapacityIsUnavailable() throws {
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("adapter-wire-\(UUID().uuidString).jsonl")
            .path
        defer { try? FileManager.default.removeItem(atPath: path) }
        let logger = AdapterWireLogger(path: path, maxPendingRecords: 0, timeSource: { 123 })

        logger.record(direction: "send", connection: UUID(), line: Data("ignored".utf8))
        logger.close()

        #expect(try Data(contentsOf: URL(fileURLWithPath: path)).isEmpty)
    }
}
