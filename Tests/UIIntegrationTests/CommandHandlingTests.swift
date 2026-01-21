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

    func testCommandToggleDiagnosticsTogglesVisibility() {
        let driver = SceneDriver()

        XCTAssertFalse(driver.diagnosticsVisible)

        driver.commandToggleDiagnostics()
        XCTAssertTrue(driver.diagnosticsVisible)

        driver.commandToggleDiagnostics()
        XCTAssertFalse(driver.diagnosticsVisible)
    }

    func testCommandToggleFullScreenInvokesHandler() {
        let handler = FullScreenHandlerSpy()
        let driver = SceneDriver(fullScreenHandler: handler)

        driver.commandToggleFullScreen()

        XCTAssertEqual(handler.toggleCount, 1)
    }
}

private final class FullScreenHandlerSpy: FullScreenHandling {
    private(set) var toggleCount = 0

    func toggleFullScreen() {
        toggleCount += 1
    }
}
