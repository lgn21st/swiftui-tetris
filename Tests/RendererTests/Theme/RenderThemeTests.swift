import XCTest
import SpriteKit
@testable import Renderer

final class RenderThemeTests: XCTestCase {
    func testBoardBackgroundColorMatchesTheme() {
        let color = RenderTheme.boardBackgroundColor.usingColorSpace(.sRGB) ?? .black
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        XCTAssertEqual(red, 28.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(green, 28.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(blue, 28.0 / 255.0, accuracy: 0.0001)
        XCTAssertEqual(alpha, 1.0, accuracy: 0.0001)
    }
}
