import Testing
@testable import UI
@testable import Core

@Suite struct InputRouterTests {
    @Test func testRoutesKeyboardActions() {
        #expect(InputRouter.action(forKey: "left") == .moveLeft)
        #expect(InputRouter.action(forKey: "up") == .rotateCw)
    }

    @Test func testRoutesUppercaseKeys() {
        #expect(InputRouter.action(forKey: "C") == .hold)
        #expect(InputRouter.action(forKey: "P") == .pause)
    }

    @Test func testRoutesGamepadActions() {
        #expect(InputRouter.action(forButton: .buttonA) == .rotateCw)
        #expect(InputRouter.action(forButton: .menu) == .pause)
    }
}
