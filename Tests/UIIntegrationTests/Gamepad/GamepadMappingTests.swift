import Testing
@testable import UI

@Suite struct GamepadMappingTests {
    @Test func testGamepadMappingReturnsActions() {
        #expect(InputRouter.action(forButton: .buttonA) == .rotateCw)
        #expect(InputRouter.action(forButton: .buttonB) == .rotateCcw)
        #expect(InputRouter.action(forButton: .buttonX) == .hardDrop)
        #expect(InputRouter.action(forButton: .buttonY) == .hold)
        #expect(InputRouter.action(forButton: .menu) == .pause)
        #expect(InputRouter.action(forButton: .options) == .restart)
    }

    @Test func testGamepadMappingShoulderButtonsRotate() {
        #expect(InputRouter.action(forButton: .leftShoulder) == .rotateCcw)
        #expect(InputRouter.action(forButton: .rightShoulder) == .rotateCw)
    }
}
