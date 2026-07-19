import Testing
import Foundation
@testable import Adapter

@Suite struct WireCodecTests {
    @Test func testLineFramerEmitsCompleteLinesAcrossChunks() throws {
        var framer = LineFramer()
        let first = Data("{\"type\":\"hello\"}\n{\"type\":\"command\"".utf8)
        let second = Data("}\n".utf8)

        let lines1 = try framer.append(first)
        #expect(lines1.count == 1)
        #expect(String(data: lines1[0], encoding: .utf8) == "{\"type\":\"hello\"}")

        let lines2 = try framer.append(second)
        #expect(lines2.count == 1)
        #expect(String(data: lines2[0], encoding: .utf8) == "{\"type\":\"command\"}")
    }

    @Test func testLineFramerRejectsInputBeyondConfiguredLimit() throws {
        var framer = LineFramer(maxLineBytes: 8)

        let error = #expect(throws: (any Error).self) {
            try framer.append(Data("123456789".utf8))
        }
        if let error {
            #expect(error as? LineFramerError == .lineTooLong)
        }
    }

    @Test func testLineFramerAcceptsCanonicalMaximumAndRejectsOneByteMore() throws {
        var accepted = LineFramer()
        let lines = try accepted.append(Data(repeating: UInt8(ascii: "x"), count: 65_536) + Data([0x0A]))
        #expect(lines.single?.count == 65_536)

        var rejected = LineFramer()
        let error = #expect(throws: (any Error).self) {
            try rejected.append(Data(repeating: UInt8(ascii: "x"), count: 65_537))
        }
        if let error {
            #expect(error as? LineFramerError == .lineTooLong)
        }
    }

    @Test func testCodecEncodesAndDecodesHello() throws {
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
            Issue.record("Expected hello message")
            return
        }

        #expect(decodedHello.protocolVersion == "3.0.0")
        #expect(decodedHello.client.name == "tetris-ai")
        #expect(decodedHello.requested.commandMode == .action)
    }

    @Test func testCodecEncodesAndDecodesCommand() throws {
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
            Issue.record("Expected command message")
            return
        }

        #expect(decodedCommand.mode == .action)
        #expect(decodedCommand.actions ?? [] == [.rotateCw, .moveLeft, .hardDrop])
        #expect(decodedCommand.restart?.seed == 123)
    }

    @Test func testCodecEncodesAndDecodesControl() throws {
        let control = TetrisAIControl(seq: 2, tsMs: 10, action: .claim)

        let data = try WireCodec.encode(.control(control))
        let decoded = try WireCodec.decode(data)

        guard case .control(let decodedControl) = decoded else {
            Issue.record("Expected control message")
            return
        }

        #expect(decodedControl.action == .claim)
    }

    @Test func testCodecRejectsModeSpecificUnknownCommandFields() {
        let data = Data(#"{"type":"command","seq":2,"ts":1,"mode":"action","actions":[],"place":{"x":0,"rotation":"north","useHold":false}}"#.utf8)
        #expect(throws: (any Error).self) {
            try WireCodec.decode(data)
        }
    }


    @Test func testWelcomeEncodesRequiredIdentityAndCapabilityPolicyFields() throws {
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
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["client_id"] as? Int == 7)
        #expect(object["role"] as? String == "observer")
        #expect(object.keys.contains("controller_id"))
        #expect(object["controller_id"] is NSNull)

        let capabilities = try #require(object["capabilities"] as? [String: Any])
        #expect(capabilities["features_always"] != nil)
        #expect(capabilities["features_optional"] != nil)
        #expect(capabilities["control_policy"] != nil)
        #expect(capabilities["formats"] as? [String] == ["json"])
        #expect((capabilities["features_always"] as? [String])?.contains("events") == true)
        #expect((capabilities["features_always"] as? [String])?.contains("logical_step") == true)
        #expect((capabilities["features_optional"] as? [String])?.contains("last_event") != true)
    }

    @Test func testAckShapesCarryCorrelationAndOnlyCommandAckCarriesAppliedState() throws {
        let control = TetrisAIAck(seq: 2, tsMs: 3, status: "ok", correlationSeq: 2)
        let controlObject = try #require(JSONSerialization.jsonObject(with: WireCodec.encode(.ack(control))) as? [String: Any])
        #expect(controlObject["correlation_seq"] as? Int == 2)
        #expect(controlObject["applied_step"] == nil)
        #expect(controlObject["state_hash"] == nil)

        let command = TetrisAIAck(
            seq: 4,
            tsMs: 5,
            status: "ok",
            correlationSeq: 4,
            appliedStep: 7,
            stateHash: "0123456789abcdef"
        )
        let commandObject = try #require(JSONSerialization.jsonObject(with: WireCodec.encode(.ack(command))) as? [String: Any])
        #expect(commandObject["applied_step"] as? Int == 7)
        #expect(commandObject["state_hash"] as? String == "0123456789abcdef")
    }
}

private extension Array {
    var single: Element? { count == 1 ? self[0] : nil }
}
