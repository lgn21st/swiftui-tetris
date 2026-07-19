import XCTest
import Core
import Foundation
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
            protocolVersion: "3.0.0",
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
        XCTAssertEqual(welcome.protocolVersion, "3.0.0")
        XCTAssertEqual(welcome.capabilities, .canonical)
    }

    func testSecondClientCannotCommand() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client1 = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 1,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )
        try client1.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client1.readLine(timeoutMs: 500)

        let client2 = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client2.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client2.readLine(timeoutMs: 500)

        let command = TetrisAICommandEnvelope(
            seq: 9,
            tsMs: 1,
            mode: .action,
            actions: [.moveLeft],
            place: nil
        )
        try client2.send(lineData: try WireCodec.encode(.command(command)))
        guard let line = try client2.readLine(timeoutMs: 500) else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error")
            return
        }
        XCTAssertEqual(error.code, "not_controller")
    }

    func testObservationBroadcastsToAllClients() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 1,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )

        let client1 = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client1.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client1.readLine(timeoutMs: 500)

        let client2 = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client2.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client2.readLine(timeoutMs: 500)

        let snapshot = GameState(config: GameConfig(), seed: 1).snapshot()
        adapter.emit(snapshot: snapshot)

        guard let line1 = try client1.readLine(timeoutMs: 500) else {
            XCTFail("Expected observation")
            return
        }
        guard let line2 = try client2.readLine(timeoutMs: 500) else {
            XCTFail("Expected observation")
            return
        }

        if case .observation = try WireCodec.decode(line1) {} else {
            XCTFail("Expected observation")
        }
        if case .observation = try WireCodec.decode(line2) {} else {
            XCTFail("Expected observation")
        }
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
            protocolVersion: "3.0.0",
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

        var state = GameState(config: GameConfig(), seed: 1)
        adapter.poll(elapsedMs: 16, state: &state)

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
        XCTAssertEqual(ack.correlationSeq, 42)
        XCTAssertEqual(ack.appliedStep, state.snapshot().logicalStep)
        XCTAssertEqual(ack.stateHash, ObservationMapper.stateHash(state.snapshot()))
        XCTAssertEqual(ack.status, "ok")
    }

    func testInvalidPlaceReceivesErrorAfterPoll() throws {
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
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .place)
        )
        try client.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client.readLine(timeoutMs: 500)

        let command = TetrisAICommandEnvelope(
            seq: 7,
            tsMs: 1,
            mode: .place,
            actions: nil,
            place: .init(x: 99, rotation: .north, useHold: false)
        )
        try client.send(lineData: try WireCodec.encode(.command(command)))

        var state = GameState(config: GameConfig(), seed: 1)
        var line: Data?
        for _ in 0..<5 {
            adapter.poll(elapsedMs: 16, state: &state)
            if let value = try client.readLine(timeoutMs: 50) {
                line = value
                break
            }
            Thread.sleep(forTimeInterval: 0.01)
        }

        guard let line else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error message")
            return
        }
        XCTAssertEqual(error.code, "invalid_place")
    }

    func testControlReleaseAndClaim() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 1,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )

        let client1 = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client1.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client1.readLine(timeoutMs: 500)

        let release = TetrisAIControl(seq: 10, tsMs: 1, action: .release)
        try client1.send(lineData: try WireCodec.encode(.control(release)))
        _ = try client1.readLine(timeoutMs: 500)

        let client2 = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client2.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client2.readLine(timeoutMs: 500)

        let claim = TetrisAIControl(seq: 11, tsMs: 1, action: .claim)
        try client2.send(lineData: try WireCodec.encode(.control(claim)))
        guard let line = try client2.readLine(timeoutMs: 1500) else {
            XCTFail("Expected ack")
            return
        }
        if case .ack = try WireCodec.decode(line) {} else {
            XCTFail("Expected ack")
        }
    }

    func testReleaseLeavesControlUnassignedUntilExplicitClaim() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 1,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )

        let client1 = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client1.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client1.readLine(timeoutMs: 500)

        let client2 = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client2.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client2.readLine(timeoutMs: 500)

        let release = TetrisAIControl(seq: 2, tsMs: 1, action: .release)
        try client1.send(lineData: try WireCodec.encode(.control(release)))
        _ = try client1.readLine(timeoutMs: 500)

        let command = TetrisAICommandEnvelope(
            seq: 3,
            tsMs: 1,
            mode: .action,
            actions: [.moveLeft],
            place: nil
        )
        try client2.send(lineData: try WireCodec.encode(.command(command)))
        var state = GameState(config: GameConfig(), seed: 1)
        adapter.poll(elapsedMs: 16, state: &state)
        guard let line = try client2.readLine(timeoutMs: 500) else {
            XCTFail("Expected not_controller")
            return
        }
        if case .error(let error) = try WireCodec.decode(line) {
            XCTAssertEqual(error.code, "not_controller")
        } else {
            XCTFail("Expected error")
        }
    }

    func testBackpressureRejectsCommand() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(
                transport: .tcp(host: "127.0.0.1", port: 0),
                maxPendingCommands: 1
            )
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
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )
        try client.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client.readLine(timeoutMs: 500)

        let first = TetrisAICommandEnvelope(
            seq: 2,
            tsMs: 1,
            mode: .action,
            actions: [.moveLeft],
            place: nil
        )
        try client.send(lineData: try WireCodec.encode(.command(first)))

        let second = TetrisAICommandEnvelope(
            seq: 3,
            tsMs: 1,
            mode: .action,
            actions: [.moveLeft],
            place: nil
        )
        try client.send(lineData: try WireCodec.encode(.command(second)))
        guard let line = try client.readLine(timeoutMs: 500) else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error")
            return
        }
        XCTAssertEqual(error.code, "backpressure")
        XCTAssertEqual(error.retryAfterMs, 50)
    }

    func testObservationThrottleSkipsFastUpdates() throws {
        var now = 0
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(
                transport: .tcp(host: "127.0.0.1", port: 0),
                observationIntervalMs: 100
            ),
            timeSource: { now }
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
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )
        try client.send(lineData: try WireCodec.encode(.hello(hello)))
        _ = try client.readLine(timeoutMs: 500)

        let snapshot = GameState(config: GameConfig(), seed: 1).snapshot()
        adapter.emit(snapshot: snapshot)
        _ = try client.readLine(timeoutMs: 500)

        now += 10
        adapter.emit(snapshot: snapshot)
        let line = try client.readLine(timeoutMs: 50)
        XCTAssertNil(line)
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
            protocolVersion: "1.0.0",
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

    func testHelloSeqNotOneReceivesInvalidCommand() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client.send(
            line: #"{"type":"hello","seq":2,"ts":1,"client":{"name":"tetris-ai","version":"0.1.0"},"protocol_version":"3.0.0","formats":["json"],"requested":{"stream_observations":true,"command_mode":"action"}}"#
        )

        guard let line = try client.readLine(timeoutMs: 500) else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error message")
            return
        }
        XCTAssertEqual(error.code, "invalid_command")
        XCTAssertEqual(error.seq, 2)
    }

    func testHelloRoleObserverNeverBecomesController() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client.send(
            line: #"{"type":"hello","seq":1,"ts":1,"client":{"name":"tetris-ai","version":"0.1.0"},"protocol_version":"3.0.0","formats":["json"],"requested":{"stream_observations":true,"command_mode":"action","role":"observer"}}"#
        )
        _ = try client.readLine(timeoutMs: 500) // welcome

        try client.send(
            line: #"{"type":"command","seq":2,"ts":1,"mode":"action","actions":["moveLeft"]}"#
        )
        var state = GameState(config: GameConfig(), seed: 1)
        var line: Data?
        for _ in 0..<5 {
            adapter.poll(elapsedMs: 16, state: &state)
            if let value = try client.readLine(timeoutMs: 50) {
                line = value
                break
            }
            Thread.sleep(forTimeInterval: 0.01)
        }

        guard let line else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error message")
            return
        }
        XCTAssertEqual(error.code, "not_controller")
        XCTAssertEqual(error.seq, 2)
    }

    func testInvalidJsonReceivesInvalidCommandError() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client.send(line: "{")

        guard let line = try client.readLine(timeoutMs: 500) else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error message")
            return
        }
        XCTAssertEqual(error.code, "invalid_command")
        XCTAssertEqual(error.seq, 0)
    }

    func testMissingRequiredFieldsReceivesInvalidCommandErrorEchoingSeq() throws {
        let adapter = SocketAdapter(
            configuration: SocketAdapterConfiguration(transport: .tcp(host: "127.0.0.1", port: 0))
        )
        defer { adapter.stop() }
        guard let port = adapter.boundPort else {
            XCTFail("Expected bound port")
            return
        }

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try client.send(line: #"{"type":"command","seq":7,"ts":1}"#)

        guard let line = try client.readLine(timeoutMs: 500) else {
            XCTFail("Expected error")
            return
        }
        let message = try WireCodec.decode(line)
        guard case .error(let error) = message else {
            XCTFail("Expected error message")
            return
        }
        XCTAssertEqual(error.code, "invalid_command")
        XCTAssertEqual(error.seq, 7)
    }

    func testStreamingHelloImmediatelyReceivesLatestFullSnapshot() throws {
        let adapter = SocketAdapter(configuration: .init(transport: .tcp(host: "127.0.0.1", port: 0)))
        defer { adapter.stop() }
        adapter.emit(snapshot: GameState(config: GameConfig(), seed: 99).snapshot())

        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: try XCTUnwrap(adapter.boundPort))
        try client.send(lineData: try WireCodec.encode(.hello(makeHello(role: .observer, stream: true))))
        guard case .welcome = try WireCodec.decode(try XCTUnwrap(client.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected welcome first")
        }
        guard case .observation(let observation) = try WireCodec.decode(try XCTUnwrap(client.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected immediate observation")
        }
        XCTAssertEqual(observation.seed, 99)
        XCTAssertEqual(observation.nextQueue.count, 5)
    }

    func testStrictSemVerAcceptsCompatibleThreeXAndRejectsMalformedVersion() throws {
        let adapter = SocketAdapter(configuration: .init(transport: .tcp(host: "127.0.0.1", port: 0)))
        defer { adapter.stop() }
        let port = try XCTUnwrap(adapter.boundPort)

        let compatible = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        var hello = makeHello(role: .observer, stream: false)
        hello.protocolVersion = "3.9.0-rc.1+build.5"
        try compatible.send(lineData: try WireCodec.encode(.hello(hello)))
        guard case .welcome = try WireCodec.decode(try XCTUnwrap(compatible.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected compatible 3.x welcome")
        }

        let malformed = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        hello.protocolVersion = "3.01.0"
        try malformed.send(lineData: try WireCodec.encode(.hello(hello)))
        guard case .error(let error) = try WireCodec.decode(try XCTUnwrap(malformed.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected protocol mismatch")
        }
        XCTAssertEqual(error.code, "protocol_mismatch")
    }

    func testVersionTwoHandshakeIsExplicitlyRejected() throws {
        let adapter = SocketAdapter(configuration: .init(transport: .tcp(host: "127.0.0.1", port: 0)))
        defer { adapter.stop() }
        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: try XCTUnwrap(adapter.boundPort))
        var hello = makeHello(role: .observer, stream: false)
        hello.protocolVersion = "2.1.1"

        try client.send(lineData: try WireCodec.encode(.hello(hello)))

        guard case .error(let error) = try WireCodec.decode(try XCTUnwrap(client.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected protocol_mismatch")
        }
        XCTAssertEqual(error.code, "protocol_mismatch")
    }

    func testObserverMayExplicitlyClaimUnassignedControl() throws {
        let adapter = SocketAdapter(configuration: .init(transport: .tcp(host: "127.0.0.1", port: 0)))
        defer { adapter.stop() }
        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: try XCTUnwrap(adapter.boundPort))
        try client.send(lineData: try WireCodec.encode(.hello(makeHello(role: .observer, stream: false))))
        _ = try client.readLine(timeoutMs: 500)
        try client.send(lineData: try WireCodec.encode(.control(.init(seq: 2, tsMs: 1, action: .claim))))
        guard case .ack(let ack) = try WireCodec.decode(try XCTUnwrap(client.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected explicit claim to succeed")
        }
        XCTAssertEqual(ack.correlationSeq, 2)
        XCTAssertNil(ack.appliedStep)
        XCTAssertNil(ack.stateHash)
    }

    func testActionLimitAndRestartPayloadSemanticsAreValidated() throws {
        let adapter = SocketAdapter(configuration: .init(transport: .tcp(host: "127.0.0.1", port: 0)))
        defer { adapter.stop() }
        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: try XCTUnwrap(adapter.boundPort))
        try client.send(lineData: try WireCodec.encode(.hello(makeHello(role: .controller, stream: false))))
        _ = try client.readLine(timeoutMs: 500)

        let actions = Array(repeating: "moveLeft", count: 33).map { "\"\($0)\"" }.joined(separator: ",")
        try client.send(line: "{\"type\":\"command\",\"seq\":2,\"ts\":1,\"mode\":\"action\",\"actions\":[\(actions)]}")
        guard case .error(let tooMany) = try WireCodec.decode(try XCTUnwrap(client.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected action limit error")
        }
        XCTAssertEqual(tooMany.code, "invalid_command")

        try client.send(line: #"{"type":"command","seq":3,"ts":1,"mode":"action","actions":["moveLeft"],"restart":{"seed":123}}"#)
        guard case .error(let invalidRestart) = try WireCodec.decode(try XCTUnwrap(client.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected restart semantic error")
        }
        XCTAssertEqual(invalidRestart.code, "invalid_command")
    }

    func testRestartSeedAppliesDeterministicallyBeforeAck() throws {
        let adapter = SocketAdapter(configuration: .init(transport: .tcp(host: "127.0.0.1", port: 0)))
        defer { adapter.stop() }
        let client = try SocketTestClient.tcp(host: "127.0.0.1", port: try XCTUnwrap(adapter.boundPort))
        try client.send(lineData: try WireCodec.encode(.hello(makeHello(role: .controller, stream: false))))
        _ = try client.readLine(timeoutMs: 500)
        let command = TetrisAICommandEnvelope(
            seq: 2, tsMs: 1, mode: .action, actions: [.restart], place: nil, restart: .init(seed: 4_294_967_295)
        )
        try client.send(lineData: try WireCodec.encode(.command(command)))
        var state = GameState(config: GameConfig(), seed: 1)
        adapter.poll(elapsedMs: 0, state: &state)
        guard case .ack(let ack) = try WireCodec.decode(try XCTUnwrap(client.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected ack")
        }
        XCTAssertEqual(state.seed, UInt64(UInt32.max))
        XCTAssertEqual(ack.correlationSeq, 2)
        XCTAssertEqual(ack.appliedStep, state.snapshot().logicalStep)
        XCTAssertEqual(ack.stateHash, ObservationMapper.stateHash(state.snapshot()))
    }

    func testDisconnectPromotionAndReconnectKeepSingleController() throws {
        let adapter = SocketAdapter(configuration: .init(transport: .tcp(host: "127.0.0.1", port: 0)))
        defer { adapter.stop() }
        let port = try XCTUnwrap(adapter.boundPort)
        let first = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        let eligible = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try first.send(lineData: try WireCodec.encode(.hello(makeHello(role: .controller, stream: false))))
        _ = try first.readLine(timeoutMs: 500)
        try eligible.send(lineData: try WireCodec.encode(.hello(makeHello(role: .auto, stream: false))))
        _ = try eligible.readLine(timeoutMs: 500)
        first.closeConnection()
        Thread.sleep(forTimeInterval: 0.05)

        try eligible.send(lineData: try WireCodec.encode(.control(.init(seq: 2, tsMs: 1, action: .claim))))
        guard case .ack = try WireCodec.decode(try XCTUnwrap(eligible.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected promoted controller")
        }

        let reconnected = try SocketTestClient.tcp(host: "127.0.0.1", port: port)
        try reconnected.send(lineData: try WireCodec.encode(.hello(makeHello(role: .controller, stream: false))))
        guard case .welcome(let welcome) = try WireCodec.decode(try XCTUnwrap(reconnected.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected reconnect welcome")
        }
        XCTAssertEqual(welcome.role, .observer)
        try reconnected.send(lineData: try WireCodec.encode(.control(.init(seq: 2, tsMs: 1, action: .claim))))
        guard case .error(let error) = try WireCodec.decode(try XCTUnwrap(reconnected.readLine(timeoutMs: 500))) else {
            return XCTFail("Expected controller_active")
        }
        XCTAssertEqual(error.code, "controller_active")
    }

    private func makeHello(role: TetrisAIRole, stream: Bool) -> TetrisAIHello {
        TetrisAIHello(
            seq: 1,
            tsMs: 1,
            client: .init(name: "tests", version: "1.0.0"),
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: stream, commandMode: .action, role: role)
        )
    }
}
