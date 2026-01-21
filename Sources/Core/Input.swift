public struct RepeatConfig: Equatable {
    public var dasMs: Int
    public var arrMs: Int

    public init(dasMs: Int = 150, arrMs: Int = 50) {
        self.dasMs = dasMs
        self.arrMs = arrMs
    }
}

public struct RepeatState {
    private(set) var held: Bool = false
    private var timeSincePressMs: Int = 0
    private var repeatsFired: Int = 0

    public init() {}

    public mutating func press() -> Bool {
        if held {
            return false
        }
        held = true
        timeSincePressMs = 0
        repeatsFired = 0
        return true
    }

    public mutating func release() {
        held = false
        timeSincePressMs = 0
        repeatsFired = 0
    }

    public mutating func tick(elapsedMs: Int, config: RepeatConfig) -> Int {
        guard held, config.arrMs != 0 else { return 0 }
        timeSincePressMs += max(elapsedMs, 0)
        if timeSincePressMs < config.dasMs {
            return 0
        }
        let total = (timeSincePressMs - config.dasMs) / config.arrMs
        let fired = max(total - repeatsFired, 0)
        repeatsFired = total
        return fired
    }

    public func isHeld() -> Bool {
        held
    }
}
