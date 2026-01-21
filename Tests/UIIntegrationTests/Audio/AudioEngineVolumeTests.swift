import XCTest
@testable import UI
@testable import Core

final class AudioEngineVolumeTests: XCTestCase {
    func testResolvedVolumeCombinesMasterAndGain() {
        let engine = AudioEngine()
        let volume = engine.resolvedVolume(for: .hardDrop, master: 0.5)
        XCTAssertEqual(volume, Float(0.2))
    }

    func testResolvedVolumeUsesOverrideGain() {
        let engine = AudioEngine()
        let volume = engine.resolvedVolume(for: .hardDrop, master: 0.5, gainOverride: 0.9)
        XCTAssertEqual(volume, Float(0.45))
    }
}
