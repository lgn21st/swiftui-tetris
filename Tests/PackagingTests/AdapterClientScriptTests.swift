import XCTest

final class AdapterClientScriptTests: XCTestCase {
    func testExampleClientUsesCurrentAdapterProtocolMajor() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let client = try String(
            contentsOf: repositoryRoot.appendingPathComponent("scripts/tetris-ai-client.py"),
            encoding: .utf8
        )

        XCTAssertTrue(client.contains(#""protocol_version": "3.0.0""#))
        XCTAssertFalse(client.contains(#""protocol_version": "2.0.0""#))
    }
}
