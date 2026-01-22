import XCTest
@testable import Packaging

final class PackagingTests: XCTestCase {
    func testInfoPlistContainsRequiredKeys() {
        let plist = Packaging.infoPlist(
            bundleID: "com.example.tetris",
            name: "SwiftUITetris",
            execName: "App",
            version: "0.1.0",
            build: "1"
        )
        XCTAssertTrue(plist.contains("CFBundleIdentifier"))
        XCTAssertTrue(plist.contains("com.example.tetris"))
        XCTAssertTrue(plist.contains("CFBundleExecutable"))
        XCTAssertTrue(plist.contains("App"))
        XCTAssertTrue(plist.contains("CFBundleShortVersionString"))
        XCTAssertTrue(plist.contains("0.1.0"))
        XCTAssertTrue(plist.contains("CFBundleVersion"))
        XCTAssertTrue(plist.contains("1"))
    }

    func testCreateBundleWritesFiles() throws {
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

        XCTAssertTrue(FileManager.default.fileExists(atPath: plistURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: bundledBinaryURL.path))
    }

    func testCreateBundleThrowsWhenBinaryMissing() throws {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("swiftui-tetris-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let bundleURL = tempDir.appendingPathComponent("SwiftUITetris.app", isDirectory: true)
        let binaryURL = tempDir.appendingPathComponent("MissingBinary")

        XCTAssertThrowsError(
            try Packaging.createAppBundle(
                binaryPath: binaryURL,
                outputBundlePath: bundleURL,
                bundleID: "com.example.tetris",
                name: "SwiftUITetris",
                version: "0.1.0",
                build: "1"
            )
        )
    }
}
