import XCTest
@testable import UI

final class AssetLocatorTests: XCTestCase {
    func testSfxDirectoryExists() {
        let url = AssetLocator.sfxDirectory()
        XCTAssertNotNil(url)
        if let url {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        }
    }

    func testSfxDirectoryPrefersBundleResourcesWhenAvailable() throws {
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
        let bundle = try XCTUnwrap(Bundle(path: bundleRoot.path))
        let located = AssetLocator.sfxDirectory(bundle: bundle, cwd: "/tmp/does-not-exist")
        XCTAssertEqual(located?.path, sfxDir.path)
    }

    func testSfxDirectoryFallsBackToCwdWhenBundleMissing() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sfxDir = tempDir.appendingPathComponent("assets/sfx", isDirectory: true)
        try FileManager.default.createDirectory(at: sfxDir, withIntermediateDirectories: true)
        let located = AssetLocator.sfxDirectory(bundle: Bundle(for: AssetLocatorTests.self), cwd: tempDir.path)
        XCTAssertEqual(located?.path, sfxDir.path)
    }
}
