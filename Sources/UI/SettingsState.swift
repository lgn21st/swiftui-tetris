import Core

public struct SettingsState: Equatable, Codable {
    public var volume: Double
    public var muted: Bool
    public var gainOverrides: [SoundEventKind: Double]
    public var sfxEnabled: [SoundEventKind: Bool]
    public var inputDasMs: Int
    public var inputArrMs: Int
    public var softDropArrMs: Int

    public static let inputDasRange = 0...300
    public static let inputArrRange = 0...100
    public static let softDropArrRange = 0...100

    public init(
        volume: Double = 0.7,
        muted: Bool = false,
        gainOverrides: [SoundEventKind: Double] = [:],
        sfxEnabled: [SoundEventKind: Bool] = [:],
        inputDasMs: Int = 150,
        inputArrMs: Int = 50,
        softDropArrMs: Int = 50
    ) {
        self.volume = volume
        self.muted = muted
        self.gainOverrides = gainOverrides
        self.sfxEnabled = sfxEnabled
        self.inputDasMs = inputDasMs
        self.inputArrMs = inputArrMs
        self.softDropArrMs = softDropArrMs
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
        sfxEnabled = [:]
        inputDasMs = 150
        inputArrMs = 50
        softDropArrMs = 50
    }

    public mutating func setGain(_ value: Double, for kind: SoundEventKind) {
        gainOverrides[kind] = min(1.0, max(0.0, value))
    }

    public mutating func setSfxEnabled(_ enabled: Bool, for kind: SoundEventKind) {
        sfxEnabled[kind] = enabled
    }

    public func isSfxEnabled(for kind: SoundEventKind) -> Bool {
        sfxEnabled[kind] ?? true
    }

    public func isSfxEnabled(for event: SoundEvent) -> Bool {
        isSfxEnabled(for: SoundEventKind.from(event: event))
    }

    public mutating func setInputDas(_ value: Int) {
        inputDasMs = Self.clamp(value, to: Self.inputDasRange)
    }

    public mutating func setInputArr(_ value: Int) {
        inputArrMs = Self.clamp(value, to: Self.inputArrRange)
    }

    public mutating func setSoftDropArr(_ value: Int) {
        softDropArrMs = Self.clamp(value, to: Self.softDropArrRange)
    }

    public func repeatConfig() -> RepeatConfig {
        RepeatConfig(dasMs: inputDasMs, arrMs: inputArrMs)
    }

    public func softDropRepeatConfig() -> RepeatConfig {
        RepeatConfig(dasMs: 0, arrMs: softDropArrMs)
    }

    public func gain(for event: SoundEvent) -> Double {
        let kind = SoundEventKind.from(event: event)
        return gainOverrides[kind] ?? SoundEventMapper.gain(for: event)
    }

    public func gainOverride(for event: SoundEvent) -> Double? {
        let kind = SoundEventKind.from(event: event)
        return gainOverrides[kind]
    }

    private static func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(range.upperBound, max(range.lowerBound, value))
    }
}
