import XCTest
@testable import Core

final class CoreTests: XCTestCase {
    func testCoreVersion() {
        XCTAssertEqual(CoreVersion.value, "0.1.0")
    }
}
