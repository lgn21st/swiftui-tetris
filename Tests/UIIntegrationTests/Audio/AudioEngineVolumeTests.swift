import Testing
@testable import UI
@testable import Core

@Suite struct AudioEngineVolumeTests {
    @Test func testResolvedVolumeCombinesMasterAndGain() {
        let engine = AudioEngine()
        let volume = engine.resolvedVolume(for: .hardDrop, master: 0.5)
        #expect(volume == Float(0.2))
    }

    @Test func testResolvedVolumeUsesOverrideGain() {
        let engine = AudioEngine()
        let volume = engine.resolvedVolume(for: .hardDrop, master: 0.5, gainOverride: 0.9)
        #expect(volume == Float(0.45))
    }
}
