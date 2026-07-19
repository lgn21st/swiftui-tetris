import Testing
@testable import UI

@Suite struct CommandHandlingTests {
    @Test func testCommandStartClearsTitleOverlay() {
        let driver = SceneDriver()

        #expect(driver.overlayState.isTitle)

        driver.commandStartGame()

        #expect(!driver.overlayState.isTitle)
    }

    @Test func testCommandTogglePauseTogglesGameState() {
        let driver = SceneDriver()
        driver.commandStartGame()

        driver.commandTogglePause()
        #expect(driver.stateSnapshot().paused)

        driver.commandTogglePause()
        #expect(!driver.stateSnapshot().paused)
    }

    @Test func testCommandRestartClearsPause() {
        let driver = SceneDriver()
        driver.commandTogglePause()

        driver.commandRestartGame()

        #expect(!driver.stateSnapshot().paused)
        #expect(!driver.overlayState.isTitle)
    }

    @Test func testToggleFullScreenInvokesHandler() {
        let handler = FullScreenHandlerSpy()
        let driver = SceneDriver(fullScreenHandler: handler)

        driver.toggleFullScreen()

        #expect(handler.toggleCount == 1)
    }
}

private final class FullScreenHandlerSpy: FullScreenHandling {
    private(set) var toggleCount = 0

    func toggleFullScreen() {
        toggleCount += 1
    }
}
