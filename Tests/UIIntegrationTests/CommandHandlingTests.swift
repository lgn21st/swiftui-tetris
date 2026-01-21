import XCTest
@testable import UI

final class CommandHandlingTests: XCTestCase {
    func testCommandStartClearsTitleOverlay() {
        let driver = SceneDriver()

        XCTAssertTrue(driver.overlayState.isTitle)

        driver.commandStartGame()

        XCTAssertFalse(driver.overlayState.isTitle)
    }

    func testCommandTogglePauseTogglesGameState() {
        let driver = SceneDriver()
        driver.commandStartGame()

        driver.commandTogglePause()
        XCTAssertTrue(driver.stateSnapshot().paused)

        driver.commandTogglePause()
        XCTAssertFalse(driver.stateSnapshot().paused)
    }

    func testCommandToggleSettingsUpdatesOverlay() {
        let driver = SceneDriver()

        driver.commandToggleSettings()
        XCTAssertTrue(driver.overlayState.isSettings)

        driver.commandToggleSettings()
        XCTAssertFalse(driver.overlayState.isSettings)
    }

    func testCommandRestartClosesSettingsAndClearsPause() {
        let driver = SceneDriver()
        driver.commandToggleSettings()
        driver.commandTogglePause()

        driver.commandRestartGame()

        XCTAssertFalse(driver.overlayState.isSettings)
        XCTAssertFalse(driver.stateSnapshot().paused)
        XCTAssertFalse(driver.overlayState.isTitle)
    }
}
