import XCTest
@testable import UI

final class LayoutConstantsTests: XCTestCase {
    func testLayoutConstantsDefaults() {
        XCTAssertEqual(LayoutConstants.basePadding, 16)
        XCTAssertEqual(LayoutConstants.baseGap, 16)
        XCTAssertEqual(LayoutConstants.panelSectionSpacing, 9.6, accuracy: 0.01)
        XCTAssertEqual(LayoutConstants.panelItemSpacing, 3.2, accuracy: 0.01)
        XCTAssertEqual(LayoutConstants.panelDividerHeight, 1)
        XCTAssertEqual(LayoutConstants.panelDividerPadding, 6)
        XCTAssertEqual(LayoutConstants.overlaySpacing, 8)
        XCTAssertEqual(LayoutConstants.hudSpacing, 6)
        XCTAssertEqual(LayoutConstants.nextPreviewCell, 10)
        XCTAssertEqual(LayoutConstants.panelCornerRadius, 8)
        XCTAssertEqual(LayoutConstants.panelShadowRadius, 10)
        XCTAssertEqual(LayoutConstants.groupCornerRadius, 12)
        XCTAssertEqual(LayoutConstants.groupBorderWidth, 1)
        XCTAssertEqual(LayoutConstants.overlayAnimationDuration, 0.12)
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

    func testOverlayAnimationRespectsReduceMotion() {
        XCTAssertNil(LayoutConstants.overlayAnimation(reduceMotion: true))
        XCTAssertNotNil(LayoutConstants.overlayAnimation(reduceMotion: false))
    }
}
