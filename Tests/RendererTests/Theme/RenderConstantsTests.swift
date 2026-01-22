import XCTest
@testable import Renderer

final class RenderConstantsTests: XCTestCase {
    func testRenderConstantsDefaults() {
        XCTAssertEqual(RenderConstants.cellSize, 24)
        XCTAssertEqual(RenderConstants.gridlineWidth, 1)
        XCTAssertEqual(RenderConstants.gridlineZ, -1)
        XCTAssertEqual(RenderConstants.activeOverlayZ, 5)
        XCTAssertEqual(RenderConstants.scorePopupFontSize, 16)
        XCTAssertEqual(RenderConstants.scorePopupZ, 10)
        XCTAssertEqual(RenderConstants.tSpinBadgeFontSize, 18)
        XCTAssertEqual(RenderConstants.tSpinBadgeZ, 12)
    }
}
