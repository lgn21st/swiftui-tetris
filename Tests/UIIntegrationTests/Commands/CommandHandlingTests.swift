import Testing
@testable import UI

@Suite @MainActor struct CommandHandlingTests {
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
        driver.tick(elapsedMs: 16)
        #expect(driver.stateSnapshot().paused)

        driver.commandTogglePause()
        driver.tick(elapsedMs: 16)
        #expect(!driver.stateSnapshot().paused)
    }

    @Test func testCommandRestartClearsPause() {
        let driver = SceneDriver()
        driver.commandTogglePause()

        driver.commandRestartGame()
        driver.tick(elapsedMs: 16)

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
