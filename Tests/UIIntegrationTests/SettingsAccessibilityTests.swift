import XCTest
@testable import UI

final class SettingsAccessibilityTests: XCTestCase {
    func testVolumeLabel() {
        XCTAssertEqual(SettingsAccessibility.volumeLabel, "Volume")
    }

    func testSfxLabelUsesKindLabel() {
        XCTAssertEqual(SettingsAccessibility.sfxLabel(for: .lineClear), "Line Clear SFX")
    }

    func testSfxToggleLabelUsesKindLabel() {
        XCTAssertEqual(SettingsAccessibility.sfxToggleLabel(for: .lineClear), "Line Clear SFX Enabled")
    }

    func testInputLabels() {
        XCTAssertEqual(SettingsAccessibility.inputDasLabel, "DAS (ms)")
        XCTAssertEqual(SettingsAccessibility.inputArrLabel, "ARR (ms)")
        XCTAssertEqual(SettingsAccessibility.softDropArrLabel, "Soft Drop ARR (ms)")
    }

    func testActionLabels() {
        XCTAssertEqual(SettingsAccessibility.resetLabel, "Reset Settings")
        XCTAssertEqual(SettingsAccessibility.closeLabel, "Close Settings")
    }
}
