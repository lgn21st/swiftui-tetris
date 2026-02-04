import XCTest
@testable import Core

final class NextQueueTests: XCTestCase {
    func testSpawnNextKeepsFivePreviewsAvailable() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.spawnNext()
        XCTAssertGreaterThanOrEqual(state.nextQueue.count, 5)
    }
}
