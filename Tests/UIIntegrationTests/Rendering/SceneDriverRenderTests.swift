import Testing
@testable import UI
@testable import Renderer
@testable import Core

@Suite @MainActor struct SceneDriverRenderTests {
    @Test func testSceneDriverTickDoesNotRenderDirectly() {
        let driver = SceneDriver(
            audio: nil,
            fullScreenHandler: FullScreenHandlerSpy()
        )
        #expect(driver.scene.debugRenderCount == 0)
        driver.tick(elapsedMs: 16)
        #expect(driver.scene.debugRenderCount == 0)
    }

    @Test func testSceneDriverSkipsRenderStateUpdateWhenPaused() {
        let driver = SceneDriver(
            audio: nil,
            fullScreenHandler: FullScreenHandlerSpy()
        )
        driver.commandStartGame()
        let baselineVersion = driver.debugRenderStateVersion

        driver.commandTogglePause()
        driver.tick(elapsedMs: 16)
        #expect(driver.debugRenderStateVersion == baselineVersion)

        driver.commandTogglePause()
        driver.tick(elapsedMs: 16)
        #expect(driver.debugRenderStateVersion > baselineVersion)
    }
}

private final class FullScreenHandlerSpy: FullScreenHandling {
    func toggleFullScreen() {}
}
