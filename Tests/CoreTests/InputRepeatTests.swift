import XCTest
@testable import Core

final class InputRepeatTests: XCTestCase {
    func testPressReturnsTrueOnce() {
        var state = RepeatState()
        XCTAssertTrue(state.press())
        XCTAssertFalse(state.press())
    }

    func testRepeatAfterDasAndArr() {
        var state = RepeatState()
        let config = RepeatConfig(dasMs: 150, arrMs: 50)
        _ = state.press()

        XCTAssertEqual(state.tick(elapsedMs: 149, config: config), 0)
        XCTAssertEqual(state.tick(elapsedMs: 1, config: config), 0)
        XCTAssertEqual(state.tick(elapsedMs: 50, config: config), 1)
        XCTAssertEqual(state.tick(elapsedMs: 50, config: config), 1)
    }

    func testReleaseResetsState() {
        var state = RepeatState()
        let config = RepeatConfig(dasMs: 150, arrMs: 50)
        _ = state.press()
        _ = state.tick(elapsedMs: 200, config: config)
        state.release()
        XCTAssertEqual(state.tick(elapsedMs: 200, config: config), 0)
    }
}
