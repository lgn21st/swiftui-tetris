import XCTest
@testable import UI

final class TypographyConstantsTests: XCTestCase {
    func testTypographyDefaults() {
        XCTAssertEqual(TypographyConstants.sidePanelFontSize, 14)
        XCTAssertEqual(TypographyConstants.sidePanelSectionFontSize, 13)
        XCTAssertEqual(TypographyConstants.sidePanelHintFontSize, 12)
        XCTAssertEqual(TypographyConstants.overlayTitleSize, 24)
        XCTAssertEqual(TypographyConstants.overlayMessageSize, 14)
        XCTAssertEqual(TypographyConstants.overlayHintSize, 12)
        XCTAssertEqual(TypographyConstants.hudFontSize, 12)
        XCTAssertEqual(TypographyConstants.hudHintFontSize, 10)
    }
}
