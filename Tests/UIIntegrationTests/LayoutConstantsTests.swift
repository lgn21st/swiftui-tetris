import XCTest
@testable import UI

final class LayoutConstantsTests: XCTestCase {
    func testLayoutConstantsDefaults() {
        XCTAssertEqual(LayoutConstants.panelSectionSpacing, 12)
        XCTAssertEqual(LayoutConstants.panelItemSpacing, 6)
        XCTAssertEqual(LayoutConstants.overlaySpacing, 8)
        XCTAssertEqual(LayoutConstants.settingsSpacing, 8)
        XCTAssertEqual(LayoutConstants.hudSpacing, 6)
        XCTAssertEqual(LayoutConstants.settingsMaxWidth, 260)
        XCTAssertEqual(LayoutConstants.panelCornerRadius, 8)
        XCTAssertEqual(LayoutConstants.panelShadowRadius, 10)
        XCTAssertEqual(LayoutConstants.settingsEnterScale, 0.96)
        XCTAssertEqual(LayoutConstants.settingsAnimationDuration, 0.18)
    }
}
