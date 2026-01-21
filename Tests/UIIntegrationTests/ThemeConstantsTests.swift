import XCTest
@testable import UI

final class ThemeConstantsTests: XCTestCase {
    func testThemeConstantsOpacities() {
        XCTAssertEqual(ThemeConstants.backgroundOpacity, 0.06)
        XCTAssertEqual(ThemeConstants.panelOpacity, 0.1)
        XCTAssertEqual(ThemeConstants.previewOpacity, 0.45)
        XCTAssertEqual(ThemeConstants.overlayOpacity, 0.55)
        XCTAssertEqual(ThemeConstants.dividerOpacity, 0.3)
        XCTAssertEqual(ThemeConstants.panelShadowOpacity, 0.0)
        XCTAssertEqual(ThemeConstants.hudBackgroundOpacity, 0.4)
        XCTAssertEqual(ThemeConstants.panelBorderOpacity, 1.0)
        XCTAssertEqual(ThemeConstants.boardBackgroundOpacity, 0.11)
        XCTAssertEqual(ThemeConstants.panelBackgroundOpacity, 0.1)
        XCTAssertEqual(ThemeConstants.appBackgroundRed, 0.06274509803921569)
        XCTAssertEqual(ThemeConstants.appBackgroundGreen, 0.06274509803921569)
        XCTAssertEqual(ThemeConstants.appBackgroundBlue, 0.06274509803921569)
        XCTAssertEqual(ThemeConstants.boardBackgroundRed, 0.10980392156862745)
        XCTAssertEqual(ThemeConstants.boardBackgroundGreen, 0.10980392156862745)
        XCTAssertEqual(ThemeConstants.boardBackgroundBlue, 0.10980392156862745)
        XCTAssertEqual(ThemeConstants.panelBackgroundRed, 0.10196078431372549)
        XCTAssertEqual(ThemeConstants.panelBackgroundGreen, 0.10196078431372549)
        XCTAssertEqual(ThemeConstants.panelBackgroundBlue, 0.10196078431372549)
        XCTAssertEqual(ThemeConstants.panelTextRed, 0.9019607843137255)
        XCTAssertEqual(ThemeConstants.panelTextGreen, 0.9019607843137255)
        XCTAssertEqual(ThemeConstants.panelTextBlue, 0.9019607843137255)
        XCTAssertEqual(ThemeConstants.borderColorRed, 0.1803921568627451)
        XCTAssertEqual(ThemeConstants.borderColorGreen, 0.1803921568627451)
        XCTAssertEqual(ThemeConstants.borderColorBlue, 0.1803921568627451)
    }
}
