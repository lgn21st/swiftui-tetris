import Testing
@testable import Renderer
@testable import Core

@Suite struct PiecePaletteTests {
    @Test func testGhostColorMatchesGridlineColor() {
        let ghostColor = PiecePalette.color(for: .t, ghost: true)
        #expect(ghostColor == RenderTheme.ghostColor)
    }
}
