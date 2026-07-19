import Testing
@testable import UI

@Suite struct FocusPauseTests {
    @Test func testFocusLossPausesGame() {
        let driver = SceneDriver()
        driver.handleKeyDown("\n")
        #expect(!driver.stateSnapshot().paused)
        driver.handleAppActiveChanged(isActive: false)
        #expect(!driver.stateSnapshot().paused)
    }

    @Test func testFocusGainDoesNotAutoUnpause() {
        let driver = SceneDriver()
        driver.handleKeyDown("\n")
        driver.handleAppActiveChanged(isActive: false)
        driver.handleAppActiveChanged(isActive: true)
        #expect(!driver.stateSnapshot().paused)
    }
}
