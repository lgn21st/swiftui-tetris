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
}

private final class FullScreenHandlerSpy: FullScreenHandling {
    func toggleFullScreen() {}
}
