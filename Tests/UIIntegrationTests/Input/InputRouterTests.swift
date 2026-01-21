import XCTest
@testable import UI
@testable import Core

final class InputRouterTests: XCTestCase {
    func testRoutesKeyboardActions() {
        XCTAssertEqual(InputRouter.action(forKey: "left"), .moveLeft)
        XCTAssertEqual(InputRouter.action(forKey: "up"), .rotateCw)
    }

    func testRoutesUppercaseKeys() {
        XCTAssertEqual(InputRouter.action(forKey: "C"), .hold)
        XCTAssertEqual(InputRouter.action(forKey: "P"), .pause)
    }

    func testRoutesGamepadActions() {
        XCTAssertEqual(InputRouter.action(forButton: .buttonA), .rotateCw)
        XCTAssertEqual(InputRouter.action(forButton: .menu), .pause)
    }
}
