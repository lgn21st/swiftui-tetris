import XCTest
@testable import UI

final class ButtonPressTrackerTests: XCTestCase {
    func testTrackerFiresOnRisingEdge() {
        var tracker = ButtonPressTracker()
        XCTAssertFalse(tracker.update(value: 0, pressed: false))
        XCTAssertTrue(tracker.update(value: 1, pressed: true))
        XCTAssertFalse(tracker.update(value: 1, pressed: true))
        XCTAssertFalse(tracker.update(value: 0, pressed: false))
        XCTAssertTrue(tracker.update(value: 1, pressed: true))
    }

    func testTrackerRespectsAnalogThreshold() {
        var tracker = ButtonPressTracker(threshold: 0.5)
        XCTAssertFalse(tracker.update(value: 0.4, pressed: false))
        XCTAssertTrue(tracker.update(value: 0.6, pressed: false))
        XCTAssertFalse(tracker.update(value: 0.6, pressed: false))
        XCTAssertFalse(tracker.update(value: 0.4, pressed: false))
    }
}
