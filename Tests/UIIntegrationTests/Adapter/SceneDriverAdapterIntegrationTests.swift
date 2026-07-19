import Testing
import Core
import Runtime
import Adapter
@testable import UI

@Suite @MainActor struct SceneDriverAdapterIntegrationTests {
    private final class SpyAdapter: GameRuntimePort {
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

    private final class LifecyclePort: GameRuntimePort, GameRuntimePortLifecycle {
        private(set) var starts = 0
        private(set) var stops = 0

        func start() { starts += 1 }
        func stop() { stops += 1 }
        func poll(elapsedMs: Int, state: inout GameState) {}
        func emit(snapshot: GameStateSnapshot) {}
    }

    @Test func runtimePortLifecycleFollowsSceneDriverLifecycle() {
        let port = LifecyclePort()
        let driver = SceneDriver(audio: nil, port: port)

        driver.start()
        driver.stop()

        #expect(port.starts == 1)
        #expect(port.stops == 1)
    }

    @Test func testTickPollsAdapterAndEmitsObservation() {
        let adapter = SpyAdapter()
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1), port: adapter)

        #expect(adapter.emitCount == 1, "initial snapshot primes streaming handshakes")

        driver.tick(elapsedMs: 16)

        #expect(adapter.pollCount == 1)
        #expect(adapter.emitCount == 2)
        #expect(adapter.lastSnapshot != nil)
    }

    @Test func testCatchUpRunsEveryFixedStepThroughAdapterBoundary() {
        let adapter = SpyAdapter()
        let driver = SceneDriver(state: GameState(config: GameConfig(), seed: 1), audio: nil, port: adapter)

        driver.tick(elapsedMs: 48)

        #expect(adapter.pollCount == 3)
        #expect(adapter.emitCount == 4)
        #expect(adapter.lastSnapshot?.stepInPiece == 3)
    }

    @Test func testFixedTransitionBeginsBeforeAdapterCommandsAndAdvancement() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.paused = true
        let transport = InMemoryTransport()
        transport.enqueueCommand(.action(actions: [.pause]))
        let adapter = InMemoryAdapter(transport: transport)
        let driver = SceneDriver(state: state, audio: nil, port: adapter)

        driver.tick(elapsedMs: 16)

        #expect(!driver.stateSnapshot().paused)
        #expect(driver.stateSnapshot().stepInPiece == 1)
        #expect(driver.stateSnapshot().logicalStep == 1)
    }

    @Test func testRemoteLockEventSurvivesUntilSameStepObservation() {
        let transport = InMemoryTransport()
        transport.enqueueCommand(.action(actions: [.hardDrop]))
        let driver = SceneDriver(
            state: GameState(config: GameConfig(), seed: 1),
            audio: nil,
            port: InMemoryAdapter(transport: transport)
        )

        driver.tick(elapsedMs: 16)

        _ = transport.dequeueObservation() // initial snapshot
        let observation = transport.dequeueObservation()
        #expect(observation?.logicalStep == 1)
        #expect(observation?.events.count == 1)
        #expect(observation?.events.first?.locked == true)
    }
}
