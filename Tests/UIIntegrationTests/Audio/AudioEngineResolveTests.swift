import Testing
@testable import UI
@testable import Core

@Suite struct AudioEngineResolveTests {
    @Test func testResolveSoundURLUsesSfxDir() {
        let base = AssetLocator.sfxDirectory()
        let engine = AudioEngine(baseURL: base)
        let url = engine.resolveURL(for: .move)
        #expect(url != nil)
    }
}
