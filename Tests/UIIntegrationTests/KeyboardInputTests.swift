import XCTest
@testable import UI
@testable import Core

final class KeyboardInputTests: XCTestCase {
    func testKeyboardMappingLeftRight() {
        XCTAssertEqual(KeyMapper.action(for: "left"), .moveLeft)
        XCTAssertEqual(KeyMapper.action(for: "right"), .moveRight)
    }

    func testKeyboardMappingRotateDropHold() {
        XCTAssertEqual(KeyMapper.action(for: "up"), .rotateCw)
        XCTAssertEqual(KeyMapper.action(for: " "), .hardDrop)
        XCTAssertEqual(KeyMapper.action(for: "c"), .hold)
    }
}
