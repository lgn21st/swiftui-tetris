import XCTest
@testable import UI

final class SettingsAccessibilityTests: XCTestCase {
    func testVolumeLabel() {
        XCTAssertEqual(SettingsAccessibility.volumeLabel, "Volume")
    }

    func testSfxLabelUsesKindLabel() {
        XCTAssertEqual(SettingsAccessibility.sfxLabel(for: .lineClear), "Line Clear SFX")
    }

    func testActionLabels() {
        XCTAssertEqual(SettingsAccessibility.resetLabel, "Reset Settings")
        XCTAssertEqual(SettingsAccessibility.closeLabel, "Close Settings")
    }
}
