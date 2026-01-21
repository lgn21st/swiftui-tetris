import XCTest
@testable import UI

final class SidePanelTypographyTests: XCTestCase {
    func testPanelTypographyHierarchyUsesDescendingSizes() {
        XCTAssertGreaterThan(
            TypographyConstants.sidePanelFontSize,
            TypographyConstants.sidePanelSectionFontSize
        )
        XCTAssertGreaterThan(
            TypographyConstants.sidePanelSectionFontSize,
            TypographyConstants.sidePanelHintFontSize
        )
    }
}
