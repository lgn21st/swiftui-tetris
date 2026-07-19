import Testing
@testable import UI

@Suite struct ButtonPressTrackerTests {
    @Test func testTrackerFiresOnRisingEdge() {
        var tracker = ButtonPressTracker()
        let idle = tracker.update(value: 0, pressed: false)
        let pressed = tracker.update(value: 1, pressed: true)
        let held = tracker.update(value: 1, pressed: true)
        let released = tracker.update(value: 0, pressed: false)
        let pressedAgain = tracker.update(value: 1, pressed: true)
        #expect(!idle)
        #expect(pressed)
        #expect(!held)
        #expect(!released)
        #expect(pressedAgain)
    }

    @Test func testTrackerRespectsAnalogThreshold() {
        var tracker = ButtonPressTracker(threshold: 0.5)
        let below = tracker.update(value: 0.4, pressed: false)
        let crossed = tracker.update(value: 0.6, pressed: false)
        let held = tracker.update(value: 0.6, pressed: false)
        let released = tracker.update(value: 0.4, pressed: false)
        #expect(!below)
        #expect(crossed)
        #expect(!held)
        #expect(!released)
    }
}
