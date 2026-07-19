import Testing
import Foundation
@testable import Packaging

@Suite struct PackagingResourcesTests {
    @Test func testBundleCopiesIconAndEntitlements() throws {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("swiftui-tetris-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let bundleURL = tempDir.appendingPathComponent("SwiftUITetris.app", isDirectory: true)
        let binaryURL = tempDir.appendingPathComponent("App")
        try "test".write(to: binaryURL, atomically: true, encoding: .utf8)

        let iconURL = tempDir.appendingPathComponent("AppIcon.icns")
        try "icon".write(to: iconURL, atomically: true, encoding: .utf8)

        let entitlementsURL = tempDir.appendingPathComponent("App.entitlements")
        try "entitlements".write(to: entitlementsURL, atomically: true, encoding: .utf8)

        try Packaging.createAppBundle(
            binaryPath: binaryURL,
            outputBundlePath: bundleURL,
            bundleID: "com.example.tetris",
            name: "SwiftUITetris",
            version: "0.1.0",
            build: "1",
            iconPath: iconURL,
            entitlementsPath: entitlementsURL
        )

        let resourcesURL = bundleURL.appendingPathComponent("Contents/Resources", isDirectory: true)
        let copiedIconURL = resourcesURL.appendingPathComponent("AppIcon.icns")
        let copiedEntitlementsURL = bundleURL.appendingPathComponent("Contents/Entitlements.plist")

        #expect(FileManager.default.fileExists(atPath: copiedIconURL.path))
        #expect(FileManager.default.fileExists(atPath: copiedEntitlementsURL.path))

        let plistURL = bundleURL.appendingPathComponent("Contents/Info.plist")
        let plist = try String(contentsOf: plistURL, encoding: .utf8)
        #expect(plist.contains("CFBundleIconFile"))
        #expect(plist.contains("AppIcon.icns"))
    }

    @Test func testBundleCopiesAssetsFolder() throws {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("swiftui-tetris-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let bundleURL = tempDir.appendingPathComponent("SwiftUITetris.app", isDirectory: true)
        let binaryURL = tempDir.appendingPathComponent("App")
        try "test".write(to: binaryURL, atomically: true, encoding: .utf8)

        let assetsURL = tempDir.appendingPathComponent("assets", isDirectory: true)
        let sfxURL = assetsURL.appendingPathComponent("sfx", isDirectory: true)
        try FileManager.default.createDirectory(at: sfxURL, withIntermediateDirectories: true)
        let soundURL = sfxURL.appendingPathComponent("move.wav")
        try "sound".write(to: soundURL, atomically: true, encoding: .utf8)
        try "metadata".write(
            to: assetsURL.appendingPathComponent(".DS_Store"),
            atomically: true,
            encoding: .utf8
        )

        try Packaging.createAppBundle(
            binaryPath: binaryURL,
            outputBundlePath: bundleURL,
            bundleID: "com.example.tetris",
            name: "SwiftUITetris",
            version: "0.1.0",
            build: "1",
            assetsPath: assetsURL
        )

        let copiedSound = bundleURL
            .appendingPathComponent("Contents/Resources/assets/sfx", isDirectory: true)
            .appendingPathComponent("move.wav")
        #expect(FileManager.default.fileExists(atPath: copiedSound.path))
        let copiedMetadata = bundleURL
            .appendingPathComponent("Contents/Resources/assets/.DS_Store")
        #expect(!FileManager.default.fileExists(atPath: copiedMetadata.path))
    }
}
