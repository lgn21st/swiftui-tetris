import Foundation

public struct FrameClock {
    private let maxDeltaMs: Double
    private var lastTime: TimeInterval?

    public init(maxDeltaMs: Double = 250) {
        self.maxDeltaMs = maxDeltaMs
        self.lastTime = nil
    }

    public mutating func advance(currentTime: TimeInterval) -> Int {
        guard let lastTime else {
            self.lastTime = currentTime
            return 0
        }
        let deltaSec = max(currentTime - lastTime, 0)
        let clampedMs = min(deltaSec * 1000.0, maxDeltaMs)
        self.lastTime = currentTime
        return Int(clampedMs.rounded())
    }
}
