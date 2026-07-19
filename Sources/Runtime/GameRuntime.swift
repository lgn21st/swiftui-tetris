import Core

public protocol GameRuntimeInput: AnyObject {
    func tick(elapsedMs: Int, canAccept: Bool, state: inout GameState)
}

public protocol GameRuntimePort: AnyObject {
    func poll(elapsedMs: Int, state: inout GameState)
    func emit(snapshot: GameStateSnapshot)
}

public final class GameRuntime {
    public static let defaultStepMs = 16
    public static let defaultMaxFrameMs = 250

    public var state: GameState
    public var snapshot: GameStateSnapshot { state.snapshot() }

    private let input: GameRuntimeInput?
    private let port: GameRuntimePort?
    private let stepMs: Int
    private let maxFrameMs: Int
    private var accumulatorMs = 0

    public init(
        state: GameState = GameState(config: GameConfig(), seed: 1),
        input: GameRuntimeInput? = nil,
        port: GameRuntimePort? = nil,
        stepMs: Int = defaultStepMs,
        maxFrameMs: Int = defaultMaxFrameMs
    ) {
        self.state = state
        self.input = input
        self.port = port
        self.stepMs = max(stepMs, 1)
        self.maxFrameMs = max(maxFrameMs, 0)
        port?.emit(snapshot: state.snapshot())
    }

    public func advance(frameMs: Int) {
        accumulatorMs += min(max(frameMs, 0), maxFrameMs)
        while accumulatorMs >= stepMs {
            accumulatorMs -= stepMs
            runStep()
        }
    }

    private func runStep() {
        state.beginFixedStep()
        port?.poll(elapsedMs: stepMs, state: &state)
        input?.tick(
            elapsedMs: stepMs,
            canAccept: !state.paused && !state.gameOver,
            state: &state
        )
        state.advanceFixedStep()
        state.tick(elapsedMs: stepMs, softDrop: false)
        port?.emit(snapshot: state.snapshot())
    }
}
