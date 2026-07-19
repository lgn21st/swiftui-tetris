import Testing
@testable import UI
@testable import Core

@Suite @MainActor struct SceneDriverInputTests {
    @Test func testSceneDriverHandlesKeyDown() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        let startX = driver.stateSnapshot().active.x
        driver.handleKeyDown("right")
        driver.tick(elapsedMs: 16)
        #expect(!driver.overlayState.isTitle)
        #expect(driver.stateSnapshot().active.x == startX + 1)
    }

    @Test func testRestartKeyClearsTitleOverlayWithoutPausing() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        #expect(driver.overlayState.isTitle)
        #expect(!driver.stateSnapshot().paused)

        driver.handleKeyDown("r")

        #expect(!driver.overlayState.isTitle)
        #expect(!driver.stateSnapshot().paused)
    }

    @Test func testPauseKeyOnTitleStartsButDoesNotPause() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        #expect(driver.overlayState.isTitle)
        #expect(!driver.stateSnapshot().paused)

        driver.handleKeyDown("p")

        #expect(!driver.overlayState.isTitle)
        #expect(!driver.stateSnapshot().paused)
    }

    @Test func testSpaceStartsGameBeforeHardDrop() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        driver.handleKeyDown(" ")
        #expect(!driver.overlayState.isTitle)
        let filled = driver.stateSnapshot().boardCells.flatMap { $0 }.contains { $0.filled }
        #expect(!filled)
        #expect(driver.stateSnapshot().score == 0)
    }

    @Test func testDiagnosticsToggle() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        #expect(!driver.diagnosticsVisible)
        driver.handleKeyDown("d")
        #expect(driver.diagnosticsVisible)
    }

    @Test func testSceneDriverRepeatsLeftAfterDasArr() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        let startX = driver.stateSnapshot().active.x
        driver.handleKeyDown("left")
        driver.tick(elapsedMs: 200)
        #expect(driver.stateSnapshot().active.x == startX - 1)
        driver.tick(elapsedMs: 8)
        #expect(driver.stateSnapshot().active.x == startX - 2)
    }

    @Test func testEscapePauses() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        driver.commandStartGame()
        #expect(!driver.stateSnapshot().paused)
        driver.handleKeyDown("escape")
        driver.tick(elapsedMs: 16)
        #expect(driver.stateSnapshot().paused)
    }

    @Test func testPauseClearsHeldMovementInput() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        let startX = driver.stateSnapshot().active.x

        driver.handleKeyDown("left")
        driver.handleKeyDown("p")
        driver.tick(elapsedMs: 200)

        #expect(driver.stateSnapshot().active.x == startX - 1)
    }

    @Test func testFocusLossClearsHeldMovementInput() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        let startX = driver.stateSnapshot().active.x

        driver.handleKeyDown("left")
        driver.handleAppActiveChanged(isActive: false)
        driver.tick(elapsedMs: 200)

        #expect(driver.stateSnapshot().active.x == startX - 1)
    }

    @Test func testDiagnosticsToggleDoesNotBlockInput() {
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1))
        let startX = driver.stateSnapshot().active.x

        driver.handleKeyDown("d")
        driver.handleKeyDown("right")
        driver.tick(elapsedMs: 16)

        #expect(driver.diagnosticsVisible)
        #expect(driver.stateSnapshot().active.x == startX + 1)
    }
}
