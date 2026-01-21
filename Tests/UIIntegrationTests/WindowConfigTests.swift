import XCTest
@testable import UI

final class WindowConfigTests: XCTestCase {
    func testWindowDefaultsMatchBaseLayout() {
        XCTAssertEqual(WindowConfig.defaultWidth, 480)
        XCTAssertEqual(WindowConfig.defaultHeight, 720)
    }

    func testWindowMinScale() {
        XCTAssertEqual(WindowConfig.minWidth, 288)
        XCTAssertEqual(WindowConfig.minHeight, 432)
    }
}
