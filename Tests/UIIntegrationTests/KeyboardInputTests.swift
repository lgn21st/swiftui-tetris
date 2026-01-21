import XCTest
@testable import UI
@testable import Core

final class KeyboardInputTests: XCTestCase {
    func testKeyboardMappingLeftRight() {
        XCTAssertEqual(InputRouter.action(forKey: "left"), .moveLeft)
        XCTAssertEqual(InputRouter.action(forKey: "right"), .moveRight)
    }

    func testKeyboardMappingRotateDropHold() {
        XCTAssertEqual(InputRouter.action(forKey: "up"), .rotateCw)
        XCTAssertEqual(InputRouter.action(forKey: " "), .hardDrop)
        XCTAssertEqual(InputRouter.action(forKey: "c"), .hold)
    }

    func testKeyCodeMapperArrows() {
        XCTAssertEqual(KeyCodeMapper.keyString(for: 123), "left")
        XCTAssertEqual(KeyCodeMapper.keyString(for: 124), "right")
        XCTAssertEqual(KeyCodeMapper.keyString(for: 125), "down")
        XCTAssertEqual(KeyCodeMapper.keyString(for: 126), "up")
    }

    func testKeyCodeMapperNonCharacterKeys() {
        XCTAssertEqual(KeyCodeMapper.keyString(for: 53), "escape")
        XCTAssertEqual(KeyCodeMapper.keyString(for: 48), "tab")
        XCTAssertEqual(KeyCodeMapper.keyString(for: 69), "+")
        XCTAssertEqual(KeyCodeMapper.keyString(for: 78), "-")
    }
}
