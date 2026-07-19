import Testing
@testable import Renderer

@Suite struct FrameClockTests {
    @Test func testFirstAdvanceReturnsZero() {
        var clock = FrameClock()
        #expect(clock.advance(currentTime: 1.0) == 0)
    }

    @Test func testReturnsRoundedDelta() {
        var clock = FrameClock(maxDeltaMs: 250)
        _ = clock.advance(currentTime: 1.0)
        #expect(clock.advance(currentTime: 1.0104) == 10)
        #expect(clock.advance(currentTime: 1.0206) == 10)
    }

    @Test func testClampsLargeDelta() {
        var clock = FrameClock(maxDeltaMs: 100)
        _ = clock.advance(currentTime: 1.0)
        #expect(clock.advance(currentTime: 2.0) == 100)
    }
}
