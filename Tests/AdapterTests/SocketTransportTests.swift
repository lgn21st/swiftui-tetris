import XCTest
@testable import Adapter

final class SocketTransportTests: XCTestCase {
    func testTcpTransportReceivesLinesFromClient() throws {
        let transport = SocketServerTransport(configuration: .tcp(host: "127.0.0.1", port: 0))
        let receiveExpectation = expectation(description: "received")
        transport.onReceive = { _, data in
            let text = String(data: data, encoding: .utf8)
            if text == "ping" {
                receiveExpectation.fulfill()
            }
        }

        try transport.start()
        guard let port = transport.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client.send(line: "ping")

        wait(for: [receiveExpectation], timeout: 2.0)
        transport.stop()
    }

    func testUnixTransportReceivesLinesFromClient() throws {
        let path = "/tmp/swiftui-tetris-ai.sock"
        let transport = SocketServerTransport(configuration: .unix(path: path), idleTimeoutMs: 500)
        let receiveExpectation = expectation(description: "received")
        transport.onReceive = { _, data in
            let text = String(data: data, encoding: .utf8)
            if text == "hello" {
                receiveExpectation.fulfill()
            }
        }

        try transport.start()

        let client = try SocketTestClient.unix(path: path)
        try client.send(line: "hello")

        wait(for: [receiveExpectation], timeout: 2.0)
        transport.stop()
    }

    func testUnixTransportStopRemovesSocketFile() throws {
        let path = "/tmp/swiftui-tetris-ai-\(UUID().uuidString).sock"
        defer { unlink(path) }

        let transport = SocketServerTransport(configuration: .unix(path: path))
        try transport.start()
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))

        transport.stop()
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
    }

    func testUnixTransportStartFailsWhenSocketAlreadyInUse() throws {
        let path = "/tmp/swiftui-tetris-ai-\(UUID().uuidString).sock"
        defer { unlink(path) }

        let transport1 = SocketServerTransport(configuration: .unix(path: path))
        try transport1.start()
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))

        let transport2 = SocketServerTransport(configuration: .unix(path: path))
        XCTAssertThrowsError(try transport2.start()) { error in
            guard case SocketTransportError.addressInUse = error else {
                XCTFail("Expected addressInUse, got: \(error)")
                return
            }
        }

        transport1.stop()
    }

    func testIdleTimeoutDisconnectsClient() throws {
        let transport = SocketServerTransport(configuration: .tcp(host: "127.0.0.1", port: 0), idleTimeoutMs: 50)
        let disconnectExpectation = expectation(description: "disconnect")
        var didDisconnect = false
        transport.onDisconnect = { _ in
            if !didDisconnect {
                didDisconnect = true
                disconnectExpectation.fulfill()
            }
        }

        try transport.start()
        guard let port = transport.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        _ = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        wait(for: [disconnectExpectation], timeout: 2.0)
        transport.stop()
    }
}
