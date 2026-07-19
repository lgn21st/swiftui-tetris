import Testing
import Foundation

@Suite struct AdapterClientScriptTests {
    @Test func testExampleClientUsesCurrentAdapterProtocolMajor() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let client = try String(
            contentsOf: repositoryRoot.appendingPathComponent("scripts/tetris-ai-client.py"),
            encoding: .utf8
        )

        #expect(client.contains(#""protocol_version": "3.0.0""#))
        #expect(!client.contains(#""protocol_version": "2.0.0""#))
    }
}
