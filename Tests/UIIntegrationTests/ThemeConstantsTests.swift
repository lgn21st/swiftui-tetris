import XCTest
@testable import UI

final class ThemeConstantsTests: XCTestCase {
    func testThemeConstantsOpacities() {
        XCTAssertEqual(ThemeConstants.backgroundOpacity, 0.85)
        XCTAssertEqual(ThemeConstants.panelOpacity, 0.6)
        XCTAssertEqual(ThemeConstants.previewOpacity, 0.45)
        XCTAssertEqual(ThemeConstants.overlayOpacity, 0.55)
        XCTAssertEqual(ThemeConstants.dividerOpacity, 0.3)
        XCTAssertEqual(ThemeConstants.panelShadowOpacity, 0.35)
        XCTAssertEqual(ThemeConstants.hudBackgroundOpacity, 0.4)
    }
}
