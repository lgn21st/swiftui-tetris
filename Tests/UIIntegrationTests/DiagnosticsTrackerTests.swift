import XCTest
@testable import UI

final class DiagnosticsTrackerTests: XCTestCase {
    func testDiagnosticsTrackerUpdatesFpsAfterWindow() {
        var tracker = DiagnosticsTracker()
        var state = DiagnosticsState.empty
        for _ in 0..<60 {
            state = tracker.recordFrame(elapsedMs: 16)
        }
        XCTAssertEqual(state.fpsText, "FPS: --")
        state = tracker.recordFrame(elapsedMs: 40)
        XCTAssertEqual(state.tickText, "Tick: 40ms")
        let parts = state.fpsText.split(separator: " ")
        let fpsValue = Int(parts.last ?? "") ?? 0
        XCTAssertTrue((60...62).contains(fpsValue))
    }
}
