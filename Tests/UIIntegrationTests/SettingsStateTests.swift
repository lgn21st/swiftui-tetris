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
}
