import Testing
@testable import UI

@Suite struct LayoutConstantsTests {
    @Test func testLayoutConstantsDefaults() {
        #expect(LayoutConstants.basePadding == 16)
        #expect(LayoutConstants.baseGap == 16)
        #expect(abs((LayoutConstants.panelSectionSpacing) - (9.6)) <= (0.01))
        #expect(abs((LayoutConstants.panelItemSpacing) - (3.2)) <= (0.01))
        #expect(LayoutConstants.panelDividerHeight == 1)
        #expect(LayoutConstants.panelDividerPadding == 6)
        #expect(LayoutConstants.overlaySpacing == 8)
        #expect(LayoutConstants.hudSpacing == 6)
        #expect(LayoutConstants.nextPreviewCell == 10)
        #expect(LayoutConstants.panelCornerRadius == 8)
        #expect(LayoutConstants.panelShadowRadius == 10)
        #expect(LayoutConstants.groupCornerRadius == 12)
        #expect(LayoutConstants.groupBorderWidth == 1)
        #expect(LayoutConstants.overlayAnimationDuration == 0.12)
        #expect(LayoutConstants.hudPadding == 8)
        #expect(LayoutConstants.hudCornerRadius == 6)
        #expect(LayoutConstants.panelBorderWidth == 1)
        #expect(LayoutConstants.boardBorderWidth == 1)
        #expect(LayoutConstants.scaleAnchor == .center)
        #expect(LayoutConstants.baseAlignment == .center)
        #expect(LayoutConstants.windowAlignment == .center)
        #expect(LayoutConstants.contentWidth == 448)
        #expect(LayoutConstants.contentHeight == 480)
    }

    @Test func testOverlayAnimationRespectsReduceMotion() {
        #expect(LayoutConstants.overlayAnimation(reduceMotion: true) == nil)
        #expect(LayoutConstants.overlayAnimation(reduceMotion: false) != nil)
    }
}
