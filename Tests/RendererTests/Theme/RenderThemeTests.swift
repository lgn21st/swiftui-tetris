import Testing
import Foundation
import SpriteKit
@testable import Renderer

@Suite struct RenderThemeTests {
    @Test func testBoardBackgroundColorMatchesTheme() {
        let color = RenderTheme.boardBackgroundColor.usingColorSpace(.sRGB) ?? .black
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        #expect(abs((red) - (28.0 / 255.0)) <= (0.0001))
        #expect(abs((green) - (28.0 / 255.0)) <= (0.0001))
        #expect(abs((blue) - (28.0 / 255.0)) <= (0.0001))
        #expect(abs((alpha) - (1.0)) <= (0.0001))
    }
}
