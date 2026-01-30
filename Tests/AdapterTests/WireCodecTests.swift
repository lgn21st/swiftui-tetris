import XCTest
@testable import Adapter

final class WireCodecTests: XCTestCase {
    func testLineFramerEmitsCompleteLinesAcrossChunks() {
        var framer = LineFramer()
        let first = Data("{\"type\":\"hello\"}\n{\"type\":\"command\"".utf8)
        let second = Data("}\n".utf8)

        let lines1 = framer.append(first)
        XCTAssertEqual(lines1.count, 1)
        XCTAssertEqual(String(data: lines1[0], encoding: .utf8), "{\"type\":\"hello\"}")

        let lines2 = framer.append(second)
        XCTAssertEqual(lines2.count, 1)
        XCTAssertEqual(String(data: lines2[0], encoding: .utf8), "{\"type\":\"command\"}")
    }

    func testCodecEncodesAndDecodesHello() throws {
        let hello = TetrisAIHello(
            seq: 1,
            tsMs: 123,
            client: .init(name: "tetris-ai", version: "0.1.0"),
            protocolVersion: "1.0.0",
            formats: [.json],
            requested: .init(streamObservations: true, commandMode: .action)
        )

        let data = try WireCodec.encode(.hello(hello))
        let decoded = try WireCodec.decode(data)

        guard case .hello(let decodedHello) = decoded else {
            XCTFail("Expected hello message")
            return
        }

        XCTAssertEqual(decodedHello.protocolVersion, "1.0.0")
        XCTAssertEqual(decodedHello.client.name, "tetris-ai")
        XCTAssertEqual(decodedHello.requested.commandMode, .action)
    }

    func testCodecEncodesAndDecodesCommand() throws {
        let command = TetrisAICommandEnvelope(
            seq: 7,
            tsMs: 456,
            mode: .action,
            actions: [.rotateCw, .moveLeft, .hardDrop],
            place: nil
        )

        let data = try WireCodec.encode(.command(command))
        let decoded = try WireCodec.decode(data)

        guard case .command(let decodedCommand) = decoded else {
            XCTFail("Expected command message")
            return
        }

        XCTAssertEqual(decodedCommand.mode, .action)
        XCTAssertEqual(decodedCommand.actions ?? [], [.rotateCw, .moveLeft, .hardDrop])
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
}
