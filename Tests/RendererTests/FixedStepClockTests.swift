import XCTest
@testable import Renderer

final class FixedStepClockTests: XCTestCase {
    func testFirstAdvanceReturnsZero() {
        var clock = FixedStepClock(stepMs: 16)
        XCTAssertEqual(clock.advance(currentTime: 1.0), 0)
    }

    func testAccumulatesFixedSteps() {
        var clock = FixedStepClock(stepMs: 16)
        _ = clock.advance(currentTime: 1.0)

        XCTAssertEqual(clock.advance(currentTime: 1.016), 1)
        XCTAssertEqual(clock.advance(currentTime: 1.032), 1)
    }

    func testAccumulatesRemainderAcrossFrames() {
        var clock = FixedStepClock(stepMs: 16)
        _ = clock.advance(currentTime: 1.0)

        XCTAssertEqual(clock.advance(currentTime: 1.010), 0)
        XCTAssertEqual(clock.advance(currentTime: 1.026), 1)
    }

    func testClampsLargeDelta() {
        var clock = FixedStepClock(stepMs: 16, maxDeltaMs: 100)
        _ = clock.advance(currentTime: 1.0)

        XCTAssertEqual(clock.advance(currentTime: 2.0), 6)
    }
}
