import XCTest
@testable import UI

final class LayoutConstantsTests: XCTestCase {
    func testLayoutConstantsDefaults() {
        XCTAssertEqual(LayoutConstants.basePadding, 16)
        XCTAssertEqual(LayoutConstants.baseGap, 16)
        XCTAssertEqual(LayoutConstants.panelSectionSpacing, 9.6, accuracy: 0.01)
        XCTAssertEqual(LayoutConstants.panelItemSpacing, 3.2, accuracy: 0.01)
        XCTAssertEqual(LayoutConstants.overlaySpacing, 8)
        XCTAssertEqual(LayoutConstants.settingsSpacing, 8)
        XCTAssertEqual(LayoutConstants.hudSpacing, 6)
        XCTAssertEqual(LayoutConstants.settingsMaxWidth, 260)
        XCTAssertEqual(LayoutConstants.panelCornerRadius, 8)
        XCTAssertEqual(LayoutConstants.panelShadowRadius, 10)
        XCTAssertEqual(LayoutConstants.settingsEnterScale, 0.96)
        XCTAssertEqual(LayoutConstants.settingsAnimationDuration, 0.18)
        XCTAssertEqual(LayoutConstants.hudPadding, 8)
        XCTAssertEqual(LayoutConstants.hudCornerRadius, 6)
        XCTAssertEqual(LayoutConstants.panelBorderWidth, 1)
        XCTAssertEqual(LayoutConstants.boardBorderWidth, 1)
        XCTAssertEqual(LayoutConstants.scaleAnchor, .center)
        XCTAssertEqual(LayoutConstants.baseAlignment, .center)
        XCTAssertEqual(LayoutConstants.windowAlignment, .center)
        XCTAssertEqual(LayoutConstants.contentWidth, 448)
        XCTAssertEqual(LayoutConstants.contentHeight, 480)
    }

    func testSettingsAnimationRespectsReduceMotion() {
        XCTAssertNil(LayoutConstants.settingsAnimation(reduceMotion: true))
        XCTAssertNotNil(LayoutConstants.settingsAnimation(reduceMotion: false))
    }
}
