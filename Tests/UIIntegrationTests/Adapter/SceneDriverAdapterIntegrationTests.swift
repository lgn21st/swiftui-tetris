import XCTest
import Core
import Adapter
@testable import UI

final class SceneDriverAdapterIntegrationTests: XCTestCase {
    private final class SpyAdapter: AdapterHandling {
        private(set) var pollCount = 0
        private(set) var emitCount = 0
        private(set) var lastSnapshot: GameStateSnapshot?

        func poll(elapsedMs: Int, state: inout GameState) {
            pollCount += 1
        }

        func emit(snapshot: GameStateSnapshot) {
            emitCount += 1
            lastSnapshot = snapshot
        }
    }

    func testTickPollsAdapterAndEmitsObservation() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let adapter = SpyAdapter()
        let driver = SceneDriver(loop: loop, adapter: adapter)

        driver.tick(elapsedMs: 16)

        XCTAssertEqual(adapter.pollCount, 1)
        XCTAssertEqual(adapter.emitCount, 1)
        XCTAssertNotNil(adapter.lastSnapshot)
    }
}
