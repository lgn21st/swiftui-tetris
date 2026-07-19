import Testing
import Foundation
import Dispatch
@testable import Adapter

@Suite struct SocketTransportTests {
    @Test func testTcpTransportReceivesLinesFromClient() throws {
        let transport = SocketServerTransport(configuration: .tcp(host: "127.0.0.1", port: 0))
        let received = DispatchSemaphore(value: 0)
        transport.onReceive = { _, data in
            let text = String(data: data, encoding: .utf8)
            if text == "ping" {
                received.signal()
            }
        }

        try transport.start()
        guard let port = transport.boundPort else {
            Issue.record("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client.send(line: "ping")

        #expect(received.wait(timeout: .now() + 2) == .success)
        transport.stop()
    }

    @Test func testTcpTransportStartFailsWhenPortAlreadyInUse() throws {
        let transport1 = SocketServerTransport(configuration: .tcp(host: "127.0.0.1", port: 0))
        try transport1.start()
        guard let port = transport1.boundPort else {
            Issue.record("Expected bound port")
            return
        }

        let transport2 = SocketServerTransport(configuration: .tcp(host: "127.0.0.1", port: port))
        let error = #expect(throws: (any Error).self) {
            try transport2.start()
        }
        if let error {
            guard case SocketTransportError.addressInUse = error else {
                Issue.record("Expected addressInUse, got: \(error)")
                return
            }
        }

        transport1.stop()
    }

    @Test func testTcpTransportRejectsInvalidHostInsteadOfBindingAllInterfaces() {
        let transport = SocketServerTransport(configuration: .tcp(host: "not-an-ip-address", port: 0))
        let error = #expect(throws: (any Error).self) {
            try transport.start()
        }
        if let error {
            guard case SocketTransportError.invalidHost = error else {
                Issue.record("Expected invalidHost, got: \(error)")
                return
            }
        }
    }

    @Test func testIdleTimeoutDisconnectsClient() throws {
        let transport = SocketServerTransport(configuration: .tcp(host: "127.0.0.1", port: 0), idleTimeoutMs: 50)
        let disconnected = DispatchSemaphore(value: 0)
        var didDisconnect = false
        transport.onDisconnect = { _ in
            if !didDisconnect {
                didDisconnect = true
                disconnected.signal()
            }
        }

        try transport.start()
        guard let port = transport.boundPort else {
            Issue.record("Expected bound port")
            return
        }

        _ = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        #expect(disconnected.wait(timeout: .now() + 2) == .success)
        transport.stop()
    }

    @Test func testTcpTransportWritesEntireLargeLine() throws {
        let transport = SocketServerTransport(
            configuration: .tcp(host: "127.0.0.1", port: 0),
            maxQueuedBytes: 1_048_576
        )
        defer { transport.stop() }
        let connected = DispatchSemaphore(value: 0)
        var connectionId: UUID?
        transport.onReceive = { id, _ in
            connectionId = id
            connected.signal()
        }

        try transport.start()
        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: try #require(transport.boundPort))
        try client.send(line: "ready")
        #expect(connected.wait(timeout: .now() + 2) == .success)

        let payload = Data(repeating: UInt8(ascii: "x"), count: 512 * 1024)
        transport.send(line: payload, to: try #require(connectionId))

        let line = try client.readLine(timeoutMs: 5_000)
        let received = try #require(line)
        #expect(received == payload)
    }

    @Test func testRequiredOutputOverflowDisconnectsOnlySlowClient() throws {
        let transport = SocketServerTransport(
            configuration: .tcp(host: "127.0.0.1", port: 0),
            maxQueuedBytes: 512
        )
        defer { transport.stop() }
        let connected = DispatchSemaphore(value: 0)
        var ids: [String: UUID] = [:]
        transport.onReceive = { id, data in
            if let name = String(data: data, encoding: .utf8), ids[name] == nil {
                ids[name] = id
                connected.signal()
            }
        }
        try transport.start()
        let port = try #require(transport.boundPort)
        let slow = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        let fast = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try slow.send(line: "slow")
        try fast.send(line: "fast")
        #expect(connected.wait(timeout: .now() + 2) == .success)
        #expect(connected.wait(timeout: .now() + 2) == .success)

        transport.send(line: Data(repeating: 1, count: 513), to: try #require(ids["slow"]), delivery: .required)
        transport.send(line: Data("ok".utf8), to: try #require(ids["fast"]), delivery: .required)

        #expect(try fast.readLine(timeoutMs: 1_000) == Data("ok".utf8))
        #expect(try slow.readLine(timeoutMs: 1_000) == nil)
    }
}
