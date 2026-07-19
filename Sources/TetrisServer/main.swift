import Foundation
import Darwin
import Core
import Runtime
import Adapter
import Headless

private let usage = """
Usage: TetrisServer [--seed <uint64>] [--steps <positive-int>] [--fast] [--auto-restart]

Runs the authoritative fixed-step Tetris runtime without SwiftUI, SpriteKit,
AppKit, or audio. Adapter endpoint and resource policy use the documented
TETRIS_AI_* environment variables.
"""

private final class ShutdownState: @unchecked Sendable {
    private let lock = NSLock()
    private var requested = false

    func request() {
        lock.lock()
        requested = true
        lock.unlock()
    }

    var shouldContinue: Bool {
        lock.lock()
        defer { lock.unlock() }
        return !requested
    }
}

private func installShutdownHandlers(state: ShutdownState) -> [DispatchSourceSignal] {
    signal(SIGINT, SIG_IGN)
    signal(SIGTERM, SIG_IGN)
    return [SIGINT, SIGTERM].map { signalNumber in
        let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .global())
        source.setEventHandler { state.request() }
        source.resume()
        return source
    }
}

let options: HeadlessServerOptions
do {
    options = try HeadlessServerOptions.parse(Array(CommandLine.arguments.dropFirst()))
} catch {
    fputs("Invalid arguments: \(error)\n\(usage)\n", stderr)
    exit(64)
}

if options.helpRequested {
    print(usage)
    exit(0)
}

let adapterConfiguration = AdapterEnvironment.configuration()
do {
    try options.validate(adapterEnabled: adapterConfiguration != nil)
} catch {
    fputs("Invalid configuration: --fast requires TETRIS_AI_DISABLED=1\n", stderr)
    exit(64)
}

let adapter: SocketAdapter?
if let configuration = adapterConfiguration {
    adapter = SocketAdapter(configuration: configuration, startsImmediately: false)
} else {
    adapter = nil
}

let runtime = GameRuntime(
    state: GameState(config: GameConfig(), seed: options.seed),
    port: adapter
)

do {
    try adapter?.startOrThrow()
} catch {
    fputs("Adapter startup failed: \(error)\n", stderr)
    exit(1)
}
defer { adapter?.stop() }

if let port = adapter?.boundPort {
    let host: String
    switch adapterConfiguration?.transport {
    case .tcp(let configuredHost, _): host = configuredHost
    case nil: host = "127.0.0.1"
    }
    print("TetrisServer protocol=3.0.0 endpoint=\(host):\(port) seed=\(options.seed)")
} else {
    print("TetrisServer adapter=disabled seed=\(options.seed)")
}

private let shutdown = ShutdownState()
private let signalSources = installShutdownHandlers(state: shutdown)
defer { signalSources.forEach { $0.cancel() } }

let scheduler: any HeadlessScheduling = options.runsAsFastAsPossible
    ? ImmediateHeadlessScheduler()
    : SystemHeadlessScheduler()
HeadlessServer(
    runtime: runtime,
    scheduler: scheduler,
    restartsOnGameOver: options.restartsOnGameOver
).run(maxSteps: options.maxSteps) {
    shutdown.shouldContinue
}
