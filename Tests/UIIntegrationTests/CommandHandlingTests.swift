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

    func testCommandRestartClearsPause() {
        let driver = SceneDriver()
        driver.commandTogglePause()

        driver.commandRestartGame()

        XCTAssertFalse(driver.stateSnapshot().paused)
        XCTAssertFalse(driver.overlayState.isTitle)
    }
}
