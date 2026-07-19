import Testing
import Core
import Adapter
@testable import UI

@Suite struct SceneDriverAdapterIntegrationTests {
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

    @Test func testTickPollsAdapterAndEmitsObservation() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let adapter = SpyAdapter()
        let driver = SceneDriver(loop: loop, adapter: adapter)

        #expect(adapter.emitCount == 1, "initial snapshot primes streaming handshakes")

        driver.tick(elapsedMs: 16)

        #expect(adapter.pollCount == 1)
        #expect(adapter.emitCount == 2)
        #expect(adapter.lastSnapshot != nil)
    }

    @Test func testCatchUpRunsEveryFixedStepThroughAdapterBoundary() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let adapter = SpyAdapter()
        let driver = SceneDriver(loop: loop, audio: nil, adapter: adapter)

        driver.tick(elapsedMs: 48, fixedSteps: 3)

        #expect(adapter.pollCount == 3)
        #expect(adapter.emitCount == 4)
        #expect(adapter.lastSnapshot?.stepInPiece == 3)
    }

    @Test func testFixedTransitionBeginsBeforeAdapterCommandsAndAdvancement() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.paused = true
        let loop = GameLoop(state: state)
        let transport = InMemoryTransport()
        transport.enqueueCommand(.action(actions: [.pause]))
        let adapter = InMemoryAdapter(transport: transport)
        let driver = SceneDriver(loop: loop, audio: nil, adapter: adapter)

        driver.tick(elapsedMs: 16)

        #expect(!driver.stateSnapshot().paused)
        #expect(driver.stateSnapshot().stepInPiece == 1)
        #expect(driver.stateSnapshot().logicalStep == 1)
    }

    @Test func testRemoteLockEventSurvivesUntilSameStepObservation() {
        let loop = GameLoop(state: GameState(config: GameConfig(), seed: 1))
        let transport = InMemoryTransport()
        transport.enqueueCommand(.action(actions: [.hardDrop]))
        let driver = SceneDriver(loop: loop, audio: nil, adapter: InMemoryAdapter(transport: transport))

        driver.tick(elapsedMs: 16)

        _ = transport.dequeueObservation() // initial snapshot
        let observation = transport.dequeueObservation()
        #expect(observation?.logicalStep == 1)
        #expect(observation?.events.count == 1)
        #expect(observation?.events.first?.locked == true)
    }
}
