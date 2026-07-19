import Testing
import Foundation
@testable import Packaging

@Suite struct PackagingTests {
    @Test func testInfoPlistContainsRequiredKeys() {
        let plist = Packaging.infoPlist(
            bundleID: "com.example.tetris",
            name: "SwiftUITetris",
            execName: "App",
            version: "0.1.0",
            build: "1"
        )
        #expect(plist.contains("CFBundleIdentifier"))
        #expect(plist.contains("com.example.tetris"))
        #expect(plist.contains("CFBundleExecutable"))
        #expect(plist.contains("App"))
        #expect(plist.contains("CFBundleShortVersionString"))
        #expect(plist.contains("0.1.0"))
        #expect(plist.contains("CFBundleVersion"))
        #expect(plist.contains("1"))
        #expect(plist.contains("<key>LSMinimumSystemVersion</key>\n    <string>14.0</string>"))
    }

    @Test func testCreateBundleWritesFiles() throws {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("swiftui-tetris-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let bundleURL = tempDir.appendingPathComponent("SwiftUITetris.app", isDirectory: true)
        let binaryURL = tempDir.appendingPathComponent("App")
        try "test".write(to: binaryURL, atomically: true, encoding: .utf8)

        try Packaging.createAppBundle(
            binaryPath: binaryURL,
            outputBundlePath: bundleURL,
            bundleID: "com.example.tetris",
            name: "SwiftUITetris",
            version: "0.1.0",
            build: "1"
        )

        let contentsURL = bundleURL.appendingPathComponent("Contents", isDirectory: true)
        let macosURL = contentsURL.appendingPathComponent("MacOS", isDirectory: true)
        let plistURL = contentsURL.appendingPathComponent("Info.plist")
        let bundledBinaryURL = macosURL.appendingPathComponent("App")

        #expect(FileManager.default.fileExists(atPath: plistURL.path))
        #expect(FileManager.default.fileExists(atPath: bundledBinaryURL.path))
    }

    @Test func testCreateBundleThrowsWhenBinaryMissing() throws {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("swiftui-tetris-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let bundleURL = tempDir.appendingPathComponent("SwiftUITetris.app", isDirectory: true)
        let binaryURL = tempDir.appendingPathComponent("MissingBinary")

        #expect(throws: (any Error).self) {
            try Packaging.createAppBundle(
                binaryPath: binaryURL,
                outputBundlePath: bundleURL,
                bundleID: "com.example.tetris",
                name: "SwiftUITetris",
                version: "0.1.0",
                build: "1"
            )
        }
    }
}
