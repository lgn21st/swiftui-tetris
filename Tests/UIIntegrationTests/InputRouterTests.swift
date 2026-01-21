import XCTest
@testable import UI
@testable import Core

final class InputRouterTests: XCTestCase {
    func testRoutesKeyboardActions() {
        XCTAssertEqual(InputRouter.action(forKey: "left"), .moveLeft)
        XCTAssertEqual(InputRouter.action(forKey: "up"), .rotateCw)
    }

    func testRoutesGamepadActions() {
        XCTAssertEqual(InputRouter.action(forButton: .buttonA), .rotateCw)
        XCTAssertEqual(InputRouter.action(forButton: .menu), .pause)
    }
}
