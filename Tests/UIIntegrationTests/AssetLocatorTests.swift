import Testing
import Foundation
@testable import UI

@Suite struct AssetLocatorTests {
    @Test func testSfxDirectoryExists() {
        let url = AssetLocator.sfxDirectory()
        #expect(url != nil)
        if let url {
            #expect(FileManager.default.fileExists(atPath: url.path))
        }
    }

    @Test func testSfxDirectoryPrefersBundleResourcesWhenAvailable() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let bundleRoot = tempDir.appendingPathComponent("Test.app", isDirectory: true)
        let contents = bundleRoot.appendingPathComponent("Contents", isDirectory: true)
        let resources = contents.appendingPathComponent("Resources", isDirectory: true)
        let sfxDir = resources.appendingPathComponent("assets/sfx", isDirectory: true)
        try FileManager.default.createDirectory(at: sfxDir, withIntermediateDirectories: true)
        let infoPlist = contents.appendingPathComponent("Info.plist")
        try "<plist version=\"1.0\"><dict></dict></plist>".write(
            to: infoPlist,
            atomically: true,
            encoding: .utf8
        )
        let bundle = try #require(Bundle(path: bundleRoot.path))
        let located = AssetLocator.sfxDirectory(bundle: bundle, cwd: "/tmp/does-not-exist")
        #expect(located?.path == sfxDir.path)
    }

    @Test func testSfxDirectoryFallsBackToCwdWhenBundleMissing() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sfxDir = tempDir.appendingPathComponent("assets/sfx", isDirectory: true)
        try FileManager.default.createDirectory(at: sfxDir, withIntermediateDirectories: true)
        let located = AssetLocator.sfxDirectory(bundle: Bundle(for: BundleToken.self), cwd: tempDir.path)
        #expect(located?.path == sfxDir.path)
    }

    private final class BundleToken: NSObject {}
}
