import XCTest
@testable import UI

final class SettingsAccessibilityTests: XCTestCase {
    func testVolumeLabel() {
        XCTAssertEqual(SettingsAccessibility.volumeLabel, "Volume")
    }

    func testSfxLabelUsesKindLabel() {
        XCTAssertEqual(SettingsAccessibility.sfxLabel(for: .lineClear), "Line Clear SFX")
    }
}
