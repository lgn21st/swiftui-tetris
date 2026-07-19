import Testing
@testable import Core

@Suite struct NextQueueTests {
    @Test func testSpawnNextKeepsFivePreviewsAvailable() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.spawnNext()
        #expect(state.nextQueue.count >= 5)
    }
}
