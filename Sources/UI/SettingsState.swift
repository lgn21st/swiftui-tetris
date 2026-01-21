public struct SettingsState: Equatable {
    public var volume: Double
    public var muted: Bool

    public init(volume: Double = 0.7, muted: Bool = false) {
        self.volume = volume
        self.muted = muted
    }

    public mutating func toggleMute() {
        muted.toggle()
    }

    public mutating func adjustVolume(by delta: Double) {
        if muted {
            muted = false
        }
        volume = min(1.0, max(0.0, volume + delta))
    }

    public mutating func reset() {
        muted = false
        volume = 0.7
    }
}
