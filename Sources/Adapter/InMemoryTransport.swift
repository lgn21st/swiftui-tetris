public final class InMemoryTransport {
    private var commandQueue: [TetrisAICommand]
    private var observationQueue: [TetrisAIObservation]
    private var commandHead: Int
    private var observationHead: Int

    public init() {
        self.commandQueue = []
        self.observationQueue = []
        self.commandHead = 0
        self.observationHead = 0
    }

    public func enqueueCommand(_ command: TetrisAICommand) {
        commandQueue.append(command)
    }

    public func dequeueCommand() -> TetrisAICommand? {
        guard commandHead < commandQueue.count else { return nil }
        let command = commandQueue[commandHead]
        commandHead += 1
        compactCommandsIfNeeded()
        return command
    }

    public func enqueueObservation(_ observation: TetrisAIObservation) {
        observationQueue.append(observation)
    }

    public func dequeueObservation() -> TetrisAIObservation? {
        guard observationHead < observationQueue.count else { return nil }
        let observation = observationQueue[observationHead]
        observationHead += 1
        compactObservationsIfNeeded()
        return observation
    }

    private func compactCommandsIfNeeded() {
        guard commandHead >= 64, commandHead * 2 >= commandQueue.count else { return }
        commandQueue.removeFirst(commandHead)
        commandHead = 0
    }

    private func compactObservationsIfNeeded() {
        guard observationHead >= 64, observationHead * 2 >= observationQueue.count else { return }
        observationQueue.removeFirst(observationHead)
        observationHead = 0
    }
}
