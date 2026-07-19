import Testing
@testable import UI
@testable import Core

@Suite struct KeyboardInputTests {
    @Test func testKeyboardMappingLeftRight() {
        #expect(InputRouter.action(forKey: "left") == .moveLeft)
        #expect(InputRouter.action(forKey: "right") == .moveRight)
    }

    @Test func testKeyboardMappingRotateDropHold() {
        #expect(InputRouter.action(forKey: "up") == .rotateCw)
        #expect(InputRouter.action(forKey: " ") == .hardDrop)
        #expect(InputRouter.action(forKey: "c") == .hold)
    }

    @Test func testKeyCodeMapperArrows() {
        #expect(KeyCodeMapper.keyString(for: 123) == "left")
        #expect(KeyCodeMapper.keyString(for: 124) == "right")
        #expect(KeyCodeMapper.keyString(for: 125) == "down")
        #expect(KeyCodeMapper.keyString(for: 126) == "up")
    }

    @Test func testKeyCodeMapperNonCharacterKeys() {
        #expect(KeyCodeMapper.keyString(for: 53) == "escape")
        #expect(KeyCodeMapper.keyString(for: 48) == "tab")
        #expect(KeyCodeMapper.keyString(for: 69) == "+")
        #expect(KeyCodeMapper.keyString(for: 78) == "-")
    }
}
