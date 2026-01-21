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

    func testSpaceStartsGameBeforeHardDrop() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        driver.handleKeyDown(" ")
        let filled = loop.state.board.cells.flatMap { $0 }.contains { $0.filled }
        XCTAssertFalse(filled)
        XCTAssertEqual(loop.state.score, 0)
    }

    func testDiagnosticsToggle() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        XCTAssertFalse(driver.diagnosticsVisible)
        driver.handleKeyDown("d")
        XCTAssertTrue(driver.diagnosticsVisible)
    }

    func testSceneDriverRepeatsLeftAfterDasArr() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x
        driver.handleKeyDown("left")
        driver.tick(elapsedMs: 200)
        XCTAssertEqual(loop.state.active.x, startX - 2)
    }

    func testEscapePauses() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        XCTAssertFalse(loop.state.paused)
        driver.handleKeyDown("escape")
        XCTAssertTrue(loop.state.paused)
    }

    func testPauseClearsHeldMovementInput() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x

        driver.handleKeyDown("left")
        driver.handleKeyDown("p")
        driver.tick(elapsedMs: 200)

        XCTAssertEqual(loop.state.active.x, startX - 1)
    }

    func testFocusLossClearsHeldMovementInput() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x

        driver.handleKeyDown("left")
        driver.handleAppActiveChanged(isActive: false)
        loop.state.paused = false
        driver.tick(elapsedMs: 200)

        XCTAssertEqual(loop.state.active.x, startX - 1)
    }

    func testDiagnosticsToggleDoesNotBlockInput() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x

        driver.handleKeyDown("d")
        driver.handleKeyDown("right")

        XCTAssertTrue(driver.diagnosticsVisible)
        XCTAssertEqual(loop.state.active.x, startX + 1)
    }
}
