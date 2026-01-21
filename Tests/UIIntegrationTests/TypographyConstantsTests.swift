import XCTest
@testable import UI

final class TypographyConstantsTests: XCTestCase {
    func testTypographyDefaults() {
        XCTAssertEqual(TypographyConstants.sidePanelFontSize, 12)
        XCTAssertEqual(TypographyConstants.sidePanelSectionFontSize, 11)
        XCTAssertEqual(TypographyConstants.sidePanelHintFontSize, 10)
        XCTAssertEqual(TypographyConstants.overlayTitleSize, 24)
        XCTAssertEqual(TypographyConstants.overlayMessageSize, 14)
        XCTAssertEqual(TypographyConstants.overlayHintSize, 12)
        XCTAssertEqual(TypographyConstants.hudFontSize, 12)
        XCTAssertEqual(TypographyConstants.hudHintFontSize, 10)
    }
}
