import Core

public struct SettingsState: Equatable, Codable {
    public var volume: Double
    public var muted: Bool
    public var gainOverrides: [SoundEventKind: Double]

    public init(volume: Double = 0.7, muted: Bool = false, gainOverrides: [SoundEventKind: Double] = [:]) {
        self.volume = volume
        self.muted = muted
        self.gainOverrides = gainOverrides
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
        gainOverrides = [:]
    }

    public mutating func setGain(_ value: Double, for kind: SoundEventKind) {
        gainOverrides[kind] = min(1.0, max(0.0, value))
    }

    public func gain(for event: SoundEvent) -> Double {
        let kind = SoundEventKind.from(event: event)
        return gainOverrides[kind] ?? SoundEventMapper.gain(for: event)
    }

    public func gainOverride(for event: SoundEvent) -> Double? {
        let kind = SoundEventKind.from(event: event)
        return gainOverrides[kind]
    }
}
