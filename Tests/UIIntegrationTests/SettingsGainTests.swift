import XCTest
@testable import UI
@testable import Core

final class SettingsGainTests: XCTestCase {
    func testSettingsGainDefaultsToMapper() {
        let settings = SettingsState()
        XCTAssertEqual(settings.gain(for: SoundEvent.move), SoundEventMapper.gain(for: SoundEvent.move))
        XCTAssertEqual(settings.gain(for: SoundEvent.lineClear(4)), SoundEventMapper.gain(for: SoundEvent.lineClear(4)))
    }

    func testSettingsGainOverrideApplies() {
        var settings = SettingsState()
        settings.setGain(0.9, for: SoundEventKind.move)
        XCTAssertEqual(settings.gain(for: SoundEvent.move), 0.9)
    }

    func testSettingsGainResetClearsOverrides() {
        var settings = SettingsState()
        settings.setGain(0.4, for: SoundEventKind.hardDrop)
        settings.reset()
        XCTAssertEqual(settings.gain(for: SoundEvent.hardDrop), SoundEventMapper.gain(for: SoundEvent.hardDrop))
    }
}
