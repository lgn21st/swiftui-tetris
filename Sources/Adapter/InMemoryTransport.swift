public final class InMemoryTransport {
    private var commandQueue: [TetrisAICommand]
    private var observationQueue: [TetrisAIObservation]

    public init() {
        self.commandQueue = []
        self.observationQueue = []
    }

    public func enqueueCommand(_ command: TetrisAICommand) {
        commandQueue.append(command)
    }

    public func dequeueCommand() -> TetrisAICommand? {
        guard !commandQueue.isEmpty else { return nil }
        return commandQueue.removeFirst()
    }

    public func enqueueObservation(_ observation: TetrisAIObservation) {
        observationQueue.append(observation)
    }

    public func dequeueObservation() -> TetrisAIObservation? {
        guard !observationQueue.isEmpty else { return nil }
        return observationQueue.removeFirst()
    }
}
