import Foundation

public struct DiagnosticsState: Equatable, Sendable {
    public var fpsText: String
    public var tickText: String

    public static let empty = DiagnosticsState(fpsText: "FPS: --", tickText: "Tick: --")
}

public struct DiagnosticsTracker {
    private var windowMs: Int
    private var frameCount: Int
    private var lastElapsedMs: Int
    private var currentFps: Int

    public init() {
        self.windowMs = 0
        self.frameCount = 0
        self.lastElapsedMs = 0
        self.currentFps = 0
    }

    public mutating func recordFrame(elapsedMs: Int) -> DiagnosticsState {
        let clamped = max(elapsedMs, 0)
        lastElapsedMs = clamped
        frameCount += 1
        windowMs += clamped
        if windowMs >= 1000 {
            if windowMs > 0 {
                currentFps = Int(round(Double(frameCount) * 1000.0 / Double(windowMs)))
            }
            windowMs = 0
            frameCount = 0
        }
        let fpsText = currentFps == 0 ? "FPS: --" : "FPS: \(currentFps)"
        let tickText = "Tick: \(lastElapsedMs)ms"
        return DiagnosticsState(fpsText: fpsText, tickText: tickText)
    }
}
