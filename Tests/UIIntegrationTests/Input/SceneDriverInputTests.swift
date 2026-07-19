import Testing
@testable import UI
@testable import Core

@Suite struct SceneDriverInputTests {
    @Test func testSceneDriverHandlesKeyDown() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x
        driver.handleKeyDown("right")
        #expect(!driver.overlayState.isTitle)
        #expect(loop.state.active.x == startX + 1)
    }

    @Test func testRestartKeyClearsTitleOverlayWithoutPausing() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        #expect(driver.overlayState.isTitle)
        #expect(!loop.state.paused)

        driver.handleKeyDown("r")

        #expect(!driver.overlayState.isTitle)
        #expect(!loop.state.paused)
    }

    @Test func testPauseKeyOnTitleStartsButDoesNotPause() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        #expect(driver.overlayState.isTitle)
        #expect(!loop.state.paused)

        driver.handleKeyDown("p")

        #expect(!driver.overlayState.isTitle)
        #expect(!loop.state.paused)
    }

    @Test func testSpaceStartsGameBeforeHardDrop() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        driver.handleKeyDown(" ")
        #expect(!driver.overlayState.isTitle)
        let filled = loop.state.board.cells.flatMap { $0 }.contains { $0.filled }
        #expect(!filled)
        #expect(loop.state.score == 0)
    }

    @Test func testDiagnosticsToggle() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        #expect(!driver.diagnosticsVisible)
        driver.handleKeyDown("d")
        #expect(driver.diagnosticsVisible)
    }

    @Test func testSceneDriverRepeatsLeftAfterDasArr() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x
        driver.handleKeyDown("left")
        driver.tick(elapsedMs: 200)
        #expect(loop.state.active.x == startX - 2)
    }

    @Test func testEscapePauses() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        driver.commandStartGame()
        #expect(!loop.state.paused)
        driver.handleKeyDown("escape")
        #expect(loop.state.paused)
    }

    @Test func testPauseClearsHeldMovementInput() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x

        driver.handleKeyDown("left")
        driver.handleKeyDown("p")
        driver.tick(elapsedMs: 200)

        #expect(loop.state.active.x == startX - 1)
    }

    @Test func testFocusLossClearsHeldMovementInput() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x

        driver.handleKeyDown("left")
        driver.handleAppActiveChanged(isActive: false)
        loop.state.paused = false
        driver.tick(elapsedMs: 200)

        #expect(loop.state.active.x == startX - 1)
    }

    @Test func testDiagnosticsToggleDoesNotBlockInput() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let driver = SceneDriver(loop: loop)
        let startX = loop.state.active.x

        driver.handleKeyDown("d")
        driver.handleKeyDown("right")

        #expect(driver.diagnosticsVisible)
        #expect(loop.state.active.x == startX + 1)
    }
}
