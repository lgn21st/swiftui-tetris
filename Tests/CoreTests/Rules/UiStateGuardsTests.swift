import Testing
@testable import Core

@Suite struct UiStateGuardsTests {
    @Test func testGameOverBlocksActionsExceptRestart() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.gameOver = true
        let startX = state.active.x
        state.apply(action: .moveRight)
        #expect(state.active.x == startX)
        state.restart(seed: 2)
        #expect(!state.gameOver)
    }

    @Test func testPausedBlocksTick() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.paused = true
        let startY = state.active.y
        state.tick(elapsedMs: 1000, softDrop: false)
        #expect(state.active.y == startY)
    }
}
