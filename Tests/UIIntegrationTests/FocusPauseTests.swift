import XCTest
@testable import UI

final class FocusPauseTests: XCTestCase {
    func testFocusLossPausesGame() {
        let driver = SceneDriver()
        driver.handleKeyDown("\n")
        XCTAssertFalse(driver.stateSnapshot().paused)
        driver.handleAppActiveChanged(isActive: false)
        XCTAssertTrue(driver.stateSnapshot().paused)
    }

    func testFocusGainDoesNotAutoUnpause() {
        let driver = SceneDriver()
        driver.handleKeyDown("\n")
        driver.handleAppActiveChanged(isActive: false)
        driver.handleAppActiveChanged(isActive: true)
        XCTAssertTrue(driver.stateSnapshot().paused)
    }
}
