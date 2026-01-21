import XCTest
@testable import UI
@testable import Core

final class SettingsStateTests: XCTestCase {
    func testToggleMute() {
        var settings = SettingsState()
        XCTAssertFalse(settings.muted)
        settings.toggleMute()
        XCTAssertTrue(settings.muted)
    }

    func testVolumeClamp() {
        var settings = SettingsState(volume: 0.95, muted: false)
        settings.adjustVolume(by: 0.2)
        XCTAssertEqual(settings.volume, 1.0)
        settings.adjustVolume(by: -2.0)
        XCTAssertEqual(settings.volume, 0.0)
    }

    func testInputDefaults() {
        let settings = SettingsState()
        XCTAssertEqual(settings.inputDasMs, 150)
        XCTAssertEqual(settings.inputArrMs, 50)
        XCTAssertEqual(settings.softDropArrMs, 50)
    }

    func testInputClamp() {
        var settings = SettingsState()
        settings.setInputDas(-10)
        settings.setInputArr(999)
        settings.setSoftDropArr(-5)
        XCTAssertEqual(settings.inputDasMs, SettingsState.inputDasRange.lowerBound)
        XCTAssertEqual(settings.inputArrMs, SettingsState.inputArrRange.upperBound)
        XCTAssertEqual(settings.softDropArrMs, SettingsState.softDropArrRange.lowerBound)
    }

    func testResetRestoresInputDefaults() {
        var settings = SettingsState()
        settings.setInputDas(0)
        settings.setInputArr(0)
        settings.setSoftDropArr(0)
        settings.reset()
        XCTAssertEqual(settings.inputDasMs, 150)
        XCTAssertEqual(settings.inputArrMs, 50)
        XCTAssertEqual(settings.softDropArrMs, 50)
    }

    func testRepeatConfigsReflectSettings() {
        var settings = SettingsState()
        settings.setInputDas(120)
        settings.setInputArr(40)
        settings.setSoftDropArr(30)
        XCTAssertEqual(settings.repeatConfig(), RepeatConfig(dasMs: 120, arrMs: 40))
        XCTAssertEqual(settings.softDropRepeatConfig(), RepeatConfig(dasMs: 0, arrMs: 30))
    }

    func testInitClampsValues() {
        let settings = SettingsState(
            volume: 2.5,
            muted: false,
            gainOverrides: [.hardDrop: 2.0],
            sfxEnabled: [:],
            inputDasMs: 999,
            inputArrMs: -10,
            softDropArrMs: 200
        )
        XCTAssertEqual(settings.volume, 1.0)
        XCTAssertEqual(settings.gainOverrides[.hardDrop], 1.0)
        XCTAssertEqual(settings.inputDasMs, SettingsState.inputDasRange.upperBound)
        XCTAssertEqual(settings.inputArrMs, SettingsState.inputArrRange.lowerBound)
        XCTAssertEqual(settings.softDropArrMs, SettingsState.softDropArrRange.upperBound)
    }

    func testSfxDefaultsEnabled() {
        let settings = SettingsState()
        XCTAssertTrue(settings.isSfxEnabled(for: SoundEventKind.hardDrop))
    }

    func testSfxTogglePersists() {
        var settings = SettingsState()
        settings.setSfxEnabled(false, for: .lineClear)
        XCTAssertFalse(settings.isSfxEnabled(for: .lineClear))
        settings.reset()
        XCTAssertTrue(settings.isSfxEnabled(for: .lineClear))
    }

    func testSfxToggleAppliesToEvents() {
        var settings = SettingsState()
        settings.setSfxEnabled(false, for: .lineClear)
        XCTAssertFalse(settings.isSfxEnabled(for: SoundEvent.lineClear(2)))
    }

    func testSfxControlReflectsToggle() {
        var settings = SettingsState()
        settings.setSfxEnabled(false, for: .rotate)
        XCTAssertFalse(settings.isSfxControlEnabled(for: .rotate))
        settings.setSfxEnabled(true, for: .rotate)
        XCTAssertTrue(settings.isSfxControlEnabled(for: .rotate))
    }

    func testGainClamp() {
        var settings = SettingsState()
        settings.setGain(2.0, for: .hardDrop)
        XCTAssertEqual(settings.gainOverrides[.hardDrop], 1.0)
        settings.setGain(-1.0, for: .hardDrop)
        XCTAssertEqual(settings.gainOverrides[.hardDrop], 0.0)
    }
}
