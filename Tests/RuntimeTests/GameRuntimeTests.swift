import Testing
import Core
@testable import Runtime

@Suite struct GameRuntimeTests {
    private final class Port: GameRuntimePort {
        var onPoll: ((inout GameState) -> Void)?
        var snapshots: [GameStateSnapshot] = []

        func poll(elapsedMs: Int, state: inout GameState) {
            onPoll?(&state)
        }

        func emit(snapshot: GameStateSnapshot) {
            snapshots.append(snapshot)
        }
    }

    private final class Input: GameRuntimeInput {
        var acceptance: [Bool] = []

        func produceActions(elapsedMs: Int, canAccept: Bool, emit: (GameAction) -> Void) {
            acceptance.append(canAccept)
        }
    }

    @Test func publishesInitialAndPerStepSnapshots() {
        let port = Port()
        let runtime = GameRuntime(state: GameState(config: GameConfig(), seed: 7), port: port)

        runtime.advance(frameMs: 48)

        #expect(port.snapshots.map(\.logicalStep) == [0, 1, 2, 3])
        #expect(runtime.snapshot.logicalStep == 3)
    }

    @Test func accumulatesPartialFramesAndClampsLargeFrames() {
        let runtime = GameRuntime(stepMs: 16, maxFrameMs: 100)

        runtime.advance(frameMs: 10)
        #expect(runtime.snapshot.logicalStep == 0)
        runtime.advance(frameMs: 6)
        #expect(runtime.snapshot.logicalStep == 1)
        runtime.advance(frameMs: 1_000)
        #expect(runtime.snapshot.logicalStep == 7)
    }

    @Test func appliesAdapterBeforeInputAndAdvancement() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.paused = true
        let port = Port()
        port.onPoll = { $0.apply(action: .pause) }
        let input = Input()
        let runtime = GameRuntime(state: state, input: input, port: port)

        runtime.advance(frameMs: 16)

        #expect(input.acceptance == [true])
        #expect(runtime.snapshot.logicalStep == 1)
        #expect(runtime.snapshot.stepInPiece == 1)
        #expect(!runtime.snapshot.paused)
    }

    @Test func runsHeadlessWithoutPlatformServices() {
        let runtime = GameRuntime(state: GameState(config: GameConfig(), seed: 3))

        runtime.advance(frameMs: 16)

        #expect(runtime.snapshot.logicalStep == 1)
        #expect(runtime.snapshot.seed == 3)
    }

    @Test func queuesLocalActionsUntilTheNextTransaction() {
        let runtime = GameRuntime(state: GameState(config: GameConfig(), seed: 1))
        let startX = runtime.snapshot.active.x

        runtime.enqueue(.moveRight)
        #expect(runtime.snapshot.active.x == startX)
        runtime.advance(frameMs: 16)

        #expect(runtime.snapshot.active.x == startX + 1)
    }
}
