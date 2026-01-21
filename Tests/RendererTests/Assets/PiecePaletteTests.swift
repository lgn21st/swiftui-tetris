import XCTest
@testable import Renderer
@testable import Core

final class PiecePaletteTests: XCTestCase {
    func testGhostColorMatchesGridlineColor() {
        let ghostColor = PiecePalette.color(for: .t, ghost: true)
        XCTAssertEqual(ghostColor, RenderTheme.ghostColor)
    }
}
