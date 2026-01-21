import XCTest
@testable import UI

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
}
