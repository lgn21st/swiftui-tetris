import XCTest
@testable import Core

final class RotationTests: XCTestCase {
    func testRotationCwCycles() {
        XCTAssertEqual(Rotation.north.cw(), .east)
        XCTAssertEqual(Rotation.east.cw(), .south)
        XCTAssertEqual(Rotation.south.cw(), .west)
        XCTAssertEqual(Rotation.west.cw(), .north)
    }

    func testRotationCcwCycles() {
        XCTAssertEqual(Rotation.north.ccw(), .west)
        XCTAssertEqual(Rotation.west.ccw(), .south)
        XCTAssertEqual(Rotation.south.ccw(), .east)
        XCTAssertEqual(Rotation.east.ccw(), .north)
    }
}
