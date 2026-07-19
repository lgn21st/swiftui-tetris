import Testing
@testable import Renderer

@Suite struct FixedStepClockTests {
    @Test func testFirstAdvanceReturnsZero() {
        var clock = FixedStepClock(stepMs: 16)
        #expect(clock.advance(currentTime: 1.0) == 0)
    }

    @Test func testAccumulatesFixedSteps() {
        var clock = FixedStepClock(stepMs: 16)
        _ = clock.advance(currentTime: 1.0)

        #expect(clock.advance(currentTime: 1.016) == 1)
        #expect(clock.advance(currentTime: 1.032) == 1)
    }

    @Test func testAccumulatesRemainderAcrossFrames() {
        var clock = FixedStepClock(stepMs: 16)
        _ = clock.advance(currentTime: 1.0)

        #expect(clock.advance(currentTime: 1.010) == 0)
        #expect(clock.advance(currentTime: 1.026) == 1)
    }

    @Test func testClampsLargeDelta() {
        var clock = FixedStepClock(stepMs: 16, maxDeltaMs: 100)
        _ = clock.advance(currentTime: 1.0)

        #expect(clock.advance(currentTime: 2.0) == 6)
    }
}
