import XCTest
import SwiftUI
@testable import UI

final class LayoutScaleTests: XCTestCase {
    func testLayoutScaleMatchesBase() {
        let size = CGSize(width: 480, height: 720)
        XCTAssertEqual(LayoutScale.scale(for: size), 1.0)
    }

    func testLayoutScaleUsesMinAxis() {
        let wide = CGSize(width: 960, height: 720)
        XCTAssertEqual(LayoutScale.scale(for: wide), 1.0)
        let tall = CGSize(width: 480, height: 1440)
        XCTAssertEqual(LayoutScale.scale(for: tall), 1.0)
    }

    func testLayoutScaleShrinks() {
        let small = CGSize(width: 240, height: 360)
        XCTAssertEqual(LayoutScale.scale(for: small), 0.6)
        let narrow = CGSize(width: 300, height: 720)
        XCTAssertEqual(LayoutScale.scale(for: narrow), 0.625)
    }
}
