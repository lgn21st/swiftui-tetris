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
}
