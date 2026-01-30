import XCTest
@testable import Adapter

final class SocketAdapterProtocolTests: XCTestCase {
    func testHelloReceivesWelcome() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 1,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "1.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )
        try client.send(lineData: try WireCodec.encode(.hello(hello)))

        guard let line = try client.readLine(timeoutMs: 500) else {
            XCTFail("Expected welcome")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .welcome(let welcome) = message else {
            XCTFail("Expected welcome message")
            return
        }
        XCTAssertEqual(welcome.protocolVersion, "1.0.0")
    }

    func testCommandBeforeHelloReceivesError() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        let command = TetrisAICommandEnvelope(
            seq: 9,
            tsMs: 1,
            mode: .action,
            actions: [.moveLeft],
            place: nil
        )
        try client.send(lineData: try WireCodec.encode(.command(command)))

        guard let line = try client.readLine(timeoutMs: 500) else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error message")
            return
        }
        XCTAssertEqual(error.code, "handshake_required")
    }

    func testCommandAfterHelloReceivesAck() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 1,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "1.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )
        try client.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client.readLine(timeoutMs: 500)

        let command = TetrisAICommandEnvelope(
            seq: 42,
            tsMs: 1,
            mode: .action,
            actions: [.rotateCw, .hardDrop],
            place: nil
        )
        try client.send(lineData: try WireCodec.encode(.command(command)))

        guard let line = try client.readLine(timeoutMs: 500) else {
            XCTFail("Expected ack")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .ack(let ack) = message else {
            XCTFail("Expected ack message")
            return
        }
        XCTAssertEqual(ack.seq, 42)
        XCTAssertEqual(ack.status, "ok")
    }

    func testHelloWithMismatchedMajorProtocolReceivesError() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 1,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "2.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )
        try client.send(lineData: try WireCodec.encode(.hello(hello)))

        guard let line = try client.readLine(timeoutMs: 500) else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error message")
            return
        }
        XCTAssertEqual(error.code, "protocol_mismatch")
    }
}
