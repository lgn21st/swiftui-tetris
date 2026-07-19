import XCTest
@testable import Adapter

final class WireCodecTests: XCTestCase {
    func testLineFramerEmitsCompleteLinesAcrossChunks() throws {
        var framer = LineFramer()
        let first = Data("{\"type\":\"hello\"}\n{\"type\":\"command\"".utf8)
        let second = Data("}\n".utf8)

        let lines1 = try framer.append(first)
        XCTAssertEqual(lines1.count, 1)
        XCTAssertEqual(String(data: lines1[0], encoding: .utf8), "{\"type\":\"hello\"}")

        let lines2 = try framer.append(second)
        XCTAssertEqual(lines2.count, 1)
        XCTAssertEqual(String(data: lines2[0], encoding: .utf8), "{\"type\":\"command\"}")
    }

    func testLineFramerRejectsInputBeyondConfiguredLimit() throws {
        var framer = LineFramer(maxLineBytes: 8)

        XCTAssertThrowsError(try framer.append(Data("123456789".utf8))) { error in
            XCTAssertEqual(error as? LineFramerError, .lineTooLong)
        }
    }

    func testLineFramerAcceptsCanonicalMaximumAndRejectsOneByteMore() throws {
        var accepted = LineFramer()
        let lines = try accepted.append(Data(repeating: UInt8(ascii: "x"), count: 65_536) + Data([0x0A]))
        XCTAssertEqual(lines.single?.count, 65_536)

        var rejected = LineFramer()
        XCTAssertThrowsError(try rejected.append(Data(repeating: UInt8(ascii: "x"), count: 65_537))) { error in
            XCTAssertEqual(error as? LineFramerError, .lineTooLong)
        }
    }

    func testCodecEncodesAndDecodesHello() throws {
        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 123,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "3.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )

        let data = try WireCodec.encode(.hello(hello))
        let decoded = try WireCodec.decode(data)

        guard case .hello(let decodedHello) = decoded else {
            XCTFail("Expected hello message")
            return
        }

        XCTAssertEqual(decodedHello.protocolVersion, "3.0.0")
        XCTAssertEqual(decodedHello.client.name, "tetris-ai")
        XCTAssertEqual(decodedHello.requested.commandMode, .action)
    }

    func testCodecEncodesAndDecodesCommand() throws {
        let command = TetrisAICommandEnvelope(
            seq: 7,
            tsMs: 456,
            mode: .action,
            actions: [.rotateCw, .moveLeft, .hardDrop],
            place: nil,
            restart: .init(seed: 123)
        )

        let data = try WireCodec.encode(.command(command))
        let decoded = try WireCodec.decode(data)

        guard case .command(let decodedCommand) = decoded else {
            XCTFail("Expected command message")
            return
        }

        XCTAssertEqual(decodedCommand.mode, .action)
        XCTAssertEqual(decodedCommand.actions ?? [], [.rotateCw, .moveLeft, .hardDrop])
        XCTAssertEqual(decodedCommand.restart?.seed, 123)
    }

    func testCodecEncodesAndDecodesControl() throws {
        let control = TetrisAIControl(seq: 2, tsMs: 10, action: .claim)

        let data = try WireCodec.encode(.control(control))
        let decoded = try WireCodec.decode(data)

        guard case .control(let decodedControl) = decoded else {
            XCTFail("Expected control message")
            return
        }

        XCTAssertEqual(decodedControl.action, .claim)
    }

    func testCodecRejectsModeSpecificUnknownCommandFields() {
        let data = Data(#"{"type":"command","seq":2,"ts":1,"mode":"action","actions":[],"place":{"x":0,"rotation":"north","useHold":false}}"#.utf8)
        XCTAssertThrowsError(try WireCodec.decode(data))
    }


    func testWelcomeEncodesRequiredIdentityAndCapabilityPolicyFields() throws {
        let welcome = TetrisAIWelcome(
            seq: 1,
            tsMs: 2,
            protocolVersion: "3.0.0",
            clientId: 7,
            role: .observer,
            controllerId: nil,
            gameId: "test",
            capabilities: .canonical
        )

        let data = try WireCodec.encode(.welcome(welcome))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["client_id"] as? Int, 7)
        XCTAssertEqual(object["role"] as? String, "observer")
        XCTAssertTrue(object.keys.contains("controller_id"))
        XCTAssertTrue(object["controller_id"] is NSNull)

        let capabilities = try XCTUnwrap(object["capabilities"] as? [String: Any])
        XCTAssertNotNil(capabilities["features_always"])
        XCTAssertNotNil(capabilities["features_optional"])
        XCTAssertNotNil(capabilities["control_policy"])
        XCTAssertEqual(capabilities["formats"] as? [String], ["json"])
        XCTAssertTrue((capabilities["features_always"] as? [String])?.contains("events") == true)
        XCTAssertTrue((capabilities["features_always"] as? [String])?.contains("logical_step") == true)
        XCTAssertFalse((capabilities["features_optional"] as? [String])?.contains("last_event") == true)
    }

    func testAckShapesCarryCorrelationAndOnlyCommandAckCarriesAppliedState() throws {
        let control = TetrisAIAck(seq: 2, tsMs: 3, status: "ok", correlationSeq: 2)
        let controlObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: WireCodec.encode(.ack(control))) as? [String: Any]
        )
        XCTAssertEqual(controlObject["correlation_seq"] as? Int, 2)
        XCTAssertNil(controlObject["applied_step"])
        XCTAssertNil(controlObject["state_hash"])

        let command = TetrisAIAck(
            seq: 4,
            tsMs: 5,
            status: "ok",
            correlationSeq: 4,
            appliedStep: 7,
            stateHash: "0123456789abcdef"
        )
        let commandObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: WireCodec.encode(.ack(command))) as? [String: Any]
        )
        XCTAssertEqual(commandObject["applied_step"] as? Int, 7)
        XCTAssertEqual(commandObject["state_hash"] as? String, "0123456789abcdef")
    }
}

private extension Array {
    var single: Element? { count == 1 ? self[0] : nil }
}
