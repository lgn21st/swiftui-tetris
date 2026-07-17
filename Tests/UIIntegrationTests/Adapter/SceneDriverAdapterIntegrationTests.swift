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

        XCTAssertEqual(adapter.emitCount, 1, "initial snapshot primes streaming handshakes")

        driver.tick(elapsedMs: 16)

        XCTAssertEqual(adapter.pollCount, 1)
        XCTAssertEqual(adapter.emitCount, 2)
        XCTAssertNotNil(adapter.lastSnapshot)
    }

    func testCatchUpRunsEveryFixedStepThroughAdapterBoundary() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let adapter = SpyAdapter()
        let driver = SceneDriver(loop: loop, audio: nil, adapter: adapter)

        driver.tick(elapsedMs: 48, fixedSteps: 3)

        XCTAssertEqual(adapter.pollCount, 3)
        XCTAssertEqual(adapter.emitCount, 4)
        XCTAssertEqual(adapter.lastSnapshot?.stepInPiece, 3)
    }

    func testAdapterCommandsApplyBeforeFixedStepBegins() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.paused = true
        let loop = GameLoop(state: state)
        let transport = InMemoryTransport()
        transport.enqueueCommand(.action(actions: [.pause]))
        let adapter = InMemoryAdapter(transport: transport)
        let driver = SceneDriver(loop: loop, audio: nil, adapter: adapter)

        driver.tick(elapsedMs: 16)

        XCTAssertFalse(driver.stateSnapshot().paused)
        XCTAssertEqual(driver.stateSnapshot().stepInPiece, 1)
    }
}
