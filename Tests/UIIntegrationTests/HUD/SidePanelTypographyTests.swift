import Testing
@testable import UI

@Suite struct SidePanelTypographyTests {
    @Test func testPanelTypographyHierarchyUsesDescendingSizes() {
        #expect(TypographyConstants.sidePanelFontSize > TypographyConstants.sidePanelSectionFontSize)
        #expect(TypographyConstants.sidePanelSectionFontSize > TypographyConstants.sidePanelHintFontSize)
    }
}
