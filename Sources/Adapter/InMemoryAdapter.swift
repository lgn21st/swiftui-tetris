import Foundation
import Core
import Runtime

public final class InMemoryAdapter: GameRuntimePort {
    private let transport: InMemoryTransport
    private let timeSource: () -> Int
    private var seq: Int

    public init(
        transport: InMemoryTransport,
        timeSource: @escaping () -> Int = InMemoryAdapter.defaultTimeSource
    ) {
        self.transport = transport
        self.timeSource = timeSource
        self.seq = 0
    }

    public func poll(elapsedMs: Int, state: inout GameState) {
        while let command = transport.dequeueCommand() {
            _ = try? AdapterCommandExecutor.execute(command, state: &state)
        }
    }

    public func emit(snapshot: GameStateSnapshot) {
        seq += 1
        let observation = ObservationMapper.map(snapshot: snapshot, seq: seq, tsMs: timeSource())
        transport.enqueueObservation(observation)
    }

    public static func defaultTimeSource() -> Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }
}
