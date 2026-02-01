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

    func testTcpTransportStartFailsWhenPortAlreadyInUse() throws {
        let transport1 = SocketServerTransport(configuration: .tcp(host: "127.0.0.1", port: 0))
        try transport1.start()
        guard let port = transport1.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let transport2 = SocketServerTransport(configuration: .tcp(host: "127.0.0.1", port: port))
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
