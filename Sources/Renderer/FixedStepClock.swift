import Foundation

public struct FixedStepClock {
    private let stepMs: Double
    private let maxDeltaMs: Double
    private var lastTime: TimeInterval?
    private var accumulatorMs: Double

    public init(stepMs: Double, maxDeltaMs: Double = 250) {
        self.stepMs = stepMs
        self.maxDeltaMs = maxDeltaMs
        self.lastTime = nil
        self.accumulatorMs = 0
    }

    public mutating func advance(currentTime: TimeInterval) -> Int {
        guard let lastTime else {
            self.lastTime = currentTime
            return 0
        }
        let deltaSec = max(currentTime - lastTime, 0)
        let clampedMs = min(deltaSec * 1000.0, maxDeltaMs)
        accumulatorMs += clampedMs
        self.lastTime = currentTime

        let steps = Int(accumulatorMs / stepMs)
        if steps > 0 {
            accumulatorMs -= Double(steps) * stepMs
        }
        return steps
    }
}
