import Testing
@testable import Core

@Suite struct CoreTests {
    @Test func testCoreVersion() {
        #expect(CoreVersion.value == "0.1.0")
    }
}
