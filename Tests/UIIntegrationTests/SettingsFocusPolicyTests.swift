import XCTest
@testable import UI

final class SettingsFocusPolicyTests: XCTestCase {
    func testSettingsFocusDefaultsToMute() {
        XCTAssertEqual(SettingsFocusPolicy.defaultField, .mute)
    }
}
