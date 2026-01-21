import XCTest
@testable import UI
@testable import Core

final class AudioEngineResolveTests: XCTestCase {
    func testResolveSoundURLUsesSfxDir() {
        let base = AssetLocator.sfxDirectory()
        let engine = AudioEngine(baseURL: base)
        let url = engine.resolveURL(for: .move)
        XCTAssertNotNil(url)
    }
}
