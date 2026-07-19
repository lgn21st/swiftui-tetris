import Testing
import Core
import Runtime
@testable import Headless

@Suite struct HeadlessServerTests {
    @Test func runsOneRuntimeTransactionPerScheduledStep() {
        let scheduler = RecordingScheduler(now: 1_000_000)
        let runtime = GameRuntime(state: GameState(config: GameConfig(), seed: 1))
        let server = HeadlessServer(runtime: runtime, scheduler: scheduler)

        server.run(maxSteps: 3)

        #expect(runtime.snapshot.logicalStep == 3)
        #expect(scheduler.deadlines == [17_000_000, 33_000_000, 49_000_000])
    }

    @Test func parsesBoundedRunOptions() throws {
        let options = try HeadlessServerOptions.parse([
            "--seed", "42", "--steps", "100", "--fast", "--auto-restart",
        ])

        #expect(options.seed == 42)
        #expect(options.maxSteps == 100)
        #expect(options.runsAsFastAsPossible)
        #expect(options.restartsOnGameOver)
    }

    @Test func stopsAtTheExternalLifecycleBoundary() {
        let scheduler = RecordingScheduler(now: 0)
        let runtime = GameRuntime(state: GameState(config: GameConfig(), seed: 1))
        let server = HeadlessServer(runtime: runtime, scheduler: scheduler)
        var checks = 0

        server.run(maxSteps: nil) {
            checks += 1
            return checks <= 2
        }

        #expect(runtime.snapshot.logicalStep == 2)
    }

    @Test func autoRestartKeepsAnUnattendedSoakPlayable() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.gameOver = true
        state.restartSeedMode = .fixed(42)
        let runtime = GameRuntime(state: state)
        let server = HeadlessServer(
            runtime: runtime,
            scheduler: RecordingScheduler(now: 0),
            restartsOnGameOver: true
        )

        server.run(maxSteps: 1)

        #expect(runtime.snapshot.episodeId == 1)
        #expect(!runtime.snapshot.gameOver)
        #expect(runtime.snapshot.seed == 42)
    }

    @Test func rejectsInvalidRunOptions() {
        #expect(throws: HeadlessServerOptions.ParseError.self) {
            try HeadlessServerOptions.parse(["--steps", "0"])
        }
        #expect(throws: HeadlessServerOptions.ParseError.self) {
            try HeadlessServerOptions.parse(["--unknown"])
        }
    }

    @Test func fastModeRequiresTheAdapterToBeDisabled() throws {
        let options = try HeadlessServerOptions.parse(["--fast"])

        #expect(throws: HeadlessServerOptions.ValidationError.self) {
            try options.validate(adapterEnabled: true)
        }
        try options.validate(adapterEnabled: false)
    }
}

private final class RecordingScheduler: HeadlessScheduling, @unchecked Sendable {
    private(set) var deadlines: [UInt64] = []
    private var current: UInt64

    init(now: UInt64) {
        self.current = now
    }

    var nowNanoseconds: UInt64 { current }

    func sleep(untilNanoseconds deadline: UInt64) {
        deadlines.append(deadline)
        current = max(current, deadline)
    }
}
