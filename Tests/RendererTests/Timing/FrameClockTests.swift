import XCTest
@testable import Renderer

final class FrameClockTests: XCTestCase {
    func testFirstAdvanceReturnsZero() {
        var clock = FrameClock()
        XCTAssertEqual(clock.advance(currentTime: 1.0), 0)
    }

    func testReturnsRoundedDelta() {
        var clock = FrameClock(maxDeltaMs: 250)
        _ = clock.advance(currentTime: 1.0)
        XCTAssertEqual(clock.advance(currentTime: 1.0104), 10)
        XCTAssertEqual(clock.advance(currentTime: 1.0206), 10)
    }

    func testClampsLargeDelta() {
        var clock = FrameClock(maxDeltaMs: 100)
        _ = clock.advance(currentTime: 1.0)
        XCTAssertEqual(clock.advance(currentTime: 2.0), 100)
    }
}
