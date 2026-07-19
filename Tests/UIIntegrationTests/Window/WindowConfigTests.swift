import Testing
@testable import UI

@Suite struct WindowConfigTests {
    @Test func testWindowDefaultsMatchBaseLayout() {
        #expect(WindowConfig.defaultWidth == 480)
        #expect(WindowConfig.defaultHeight == 720)
    }

    @Test func testWindowMinScale() {
        #expect(WindowConfig.minWidth == 288)
        #expect(WindowConfig.minHeight == 432)
    }

    @Test func testWindowResizabilityFlag() {
        #expect(WindowConfig.allowsResize)
    }
}
