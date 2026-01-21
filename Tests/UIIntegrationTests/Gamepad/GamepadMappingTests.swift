import XCTest
@testable import UI

final class GamepadMappingTests: XCTestCase {
    func testGamepadMappingReturnsActions() {
        XCTAssertEqual(InputRouter.action(forButton: .buttonA), .rotateCw)
        XCTAssertEqual(InputRouter.action(forButton: .buttonB), .rotateCcw)
        XCTAssertEqual(InputRouter.action(forButton: .buttonX), .hardDrop)
        XCTAssertEqual(InputRouter.action(forButton: .buttonY), .hold)
        XCTAssertEqual(InputRouter.action(forButton: .menu), .pause)
        XCTAssertEqual(InputRouter.action(forButton: .options), .restart)
    }

    func testGamepadMappingShoulderButtonsRotate() {
        XCTAssertEqual(InputRouter.action(forButton: .leftShoulder), .rotateCcw)
        XCTAssertEqual(InputRouter.action(forButton: .rightShoulder), .rotateCw)
    }
}
