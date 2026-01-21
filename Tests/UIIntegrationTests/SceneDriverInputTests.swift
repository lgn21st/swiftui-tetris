import XCTest
@testable import UI
@testable import Core

final class SceneDriverInputTests: XCTestCase {
    func testSceneDriverHandlesKeyDown() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x
        driver.handleKeyDown("right")
        XCTAssertEqual(loop.state.active.x, startX + 1)
    }
}
