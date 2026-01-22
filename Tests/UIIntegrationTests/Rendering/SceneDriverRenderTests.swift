import XCTest
@testable import UI
@testable import Renderer
@testable import Core

final class SceneDriverRenderTests: XCTestCase {
    func testSceneDriverTickDoesNotRenderDirectly() {
        let driver = SceneDriver(
            audio: nil,
            fullScreenHandler: FullScreenHandlerSpy()
        )
        XCTAssertEqual(driver.scene.debugRenderCount, 0)
        driver.tick(elapsedMs: 16)
        XCTAssertEqual(driver.scene.debugRenderCount, 0)
    }

    func testSceneDriverSkipsRenderStateUpdateWhenPaused() {
        let driver = SceneDriver(
            audio: nil,
            fullScreenHandler: FullScreenHandlerSpy()
        )
        driver.commandStartGame()
        let baselineVersion = driver.debugRenderStateVersion

        driver.commandTogglePause()
        driver.tick(elapsedMs: 16)
        XCTAssertEqual(driver.debugRenderStateVersion, baselineVersion)

        driver.commandTogglePause()
        driver.tick(elapsedMs: 16)
        XCTAssertGreaterThan(driver.debugRenderStateVersion, baselineVersion)
    }
}

private final class FullScreenHandlerSpy: FullScreenHandling {
    func toggleFullScreen() {}
}
