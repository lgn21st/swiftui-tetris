import XCTest
@testable import UI

final class GamepadMappingTests: XCTestCase {
    func testGamepadMappingReturnsActions() {
        XCTAssertEqual(GamepadMapping.action(for: .buttonA), .rotateCw)
        XCTAssertEqual(GamepadMapping.action(for: .buttonB), .rotateCcw)
        XCTAssertEqual(GamepadMapping.action(for: .buttonX), .hardDrop)
        XCTAssertEqual(GamepadMapping.action(for: .buttonY), .hold)
        XCTAssertEqual(GamepadMapping.action(for: .menu), .pause)
        XCTAssertEqual(GamepadMapping.action(for: .options), .restart)
    }

    func testGamepadMappingShoulderButtonsRotate() {
        XCTAssertEqual(GamepadMapping.action(for: .leftShoulder), .rotateCcw)
        XCTAssertEqual(GamepadMapping.action(for: .rightShoulder), .rotateCw)
    }
}
