import Testing
import SwiftUI
@testable import UI

@Suite struct LayoutScaleTests {
    @Test func testLayoutScaleMatchesBase() {
        let size = CGSize(width: 480, height: 720)
        #expect(LayoutScale.scale(for: size) == 1.0)
    }

    @Test func testLayoutScaleUsesMinAxis() {
        let wide = CGSize(width: 960, height: 720)
        #expect(LayoutScale.scale(for: wide) == 1.0)
        let tall = CGSize(width: 480, height: 1440)
        #expect(LayoutScale.scale(for: tall) == 1.0)
    }

    @Test func testLayoutScaleShrinks() {
        let small = CGSize(width: 240, height: 360)
        #expect(LayoutScale.scale(for: small) == 0.6)
        let narrow = CGSize(width: 300, height: 720)
        #expect(LayoutScale.scale(for: narrow) == 0.625)
    }
}
