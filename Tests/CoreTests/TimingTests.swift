import XCTest
@testable import Core

final class TimingTests: XCTestCase {
    func testDropIntervalTableAndFloor() {
        XCTAssertEqual(Timing.dropInterval(level: 0, baseDropMs: 1000, softDrop: false, softDropMultiplier: 10), 1000)
        XCTAssertEqual(Timing.dropInterval(level: 1, baseDropMs: 1000, softDrop: false, softDropMultiplier: 10), 800)
        XCTAssertEqual(Timing.dropInterval(level: 8, baseDropMs: 1000, softDrop: false, softDropMultiplier: 10), 160)
        XCTAssertEqual(Timing.dropInterval(level: 9, baseDropMs: 1000, softDrop: false, softDropMultiplier: 10), 120)
    }

    func testDropIntervalClampsToBaseAndMinimum() {
        XCTAssertEqual(Timing.dropInterval(level: 0, baseDropMs: 900, softDrop: false, softDropMultiplier: 10), 900)
        XCTAssertEqual(Timing.dropInterval(level: 0, baseDropMs: 50, softDrop: false, softDropMultiplier: 10), 100)
    }

    func testSoftDropIntervalUsesMultiplier() {
        XCTAssertEqual(Timing.dropInterval(level: 0, baseDropMs: 1000, softDrop: true, softDropMultiplier: 10), 100)
        XCTAssertEqual(Timing.dropInterval(level: 0, baseDropMs: 1000, softDrop: true, softDropMultiplier: 0), 1000)
    }
}
