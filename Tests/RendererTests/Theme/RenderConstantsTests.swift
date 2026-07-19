import Testing
@testable import Renderer

@Suite struct RenderConstantsTests {
    @Test func testRenderConstantsDefaults() {
        #expect(RenderConstants.cellSize == 24)
        #expect(RenderConstants.gridlineWidth == 1)
        #expect(RenderConstants.gridlineZ == -1)
        #expect(RenderConstants.activeOverlayZ == 5)
        #expect(RenderConstants.scorePopupFontSize == 16)
        #expect(RenderConstants.scorePopupZ == 10)
        #expect(RenderConstants.tSpinBadgeFontSize == 18)
        #expect(RenderConstants.tSpinBadgeZ == 12)
    }
}
