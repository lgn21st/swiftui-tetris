import Testing
@testable import UI

@Suite struct TypographyConstantsTests {
    @Test func testTypographyDefaults() {
        #expect(TypographyConstants.sidePanelFontSize == 14)
        #expect(TypographyConstants.sidePanelSectionFontSize == 13)
        #expect(TypographyConstants.sidePanelHintFontSize == 12)
        #expect(TypographyConstants.overlayTitleSize == 24)
        #expect(TypographyConstants.overlayMessageSize == 14)
        #expect(TypographyConstants.overlayHintSize == 12)
        #expect(TypographyConstants.hudFontSize == 12)
        #expect(TypographyConstants.hudHintFontSize == 10)
    }
}
