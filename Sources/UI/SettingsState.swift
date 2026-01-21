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

    private enum CodingKeys: String, CodingKey {
        case volume
        case muted
        case gainOverrides
        case sfxEnabled
        case inputDasMs
        case inputArrMs
        case softDropArrMs
    }

    public init(
        volume: Double = 0.7,
        muted: Bool = false,
        gainOverrides: [SoundEventKind: Double] = [:],
        sfxEnabled: [SoundEventKind: Bool] = [:],
        inputDasMs: Int = 150,
        inputArrMs: Int = 50,
        softDropArrMs: Int = 50
    ) {
        self.volume = min(1.0, max(0.0, volume))
        self.muted = muted
        self.gainOverrides = gainOverrides.mapValues { min(1.0, max(0.0, $0)) }
        self.sfxEnabled = sfxEnabled
        self.inputDasMs = Self.clamp(inputDasMs, to: Self.inputDasRange)
        self.inputArrMs = Self.clamp(inputArrMs, to: Self.inputArrRange)
        self.softDropArrMs = Self.clamp(softDropArrMs, to: Self.softDropArrRange)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let volume = try container.decodeIfPresent(Double.self, forKey: .volume) ?? 0.7
        let muted = try container.decodeIfPresent(Bool.self, forKey: .muted) ?? false
        let gainOverrides = try container.decodeIfPresent([SoundEventKind: Double].self, forKey: .gainOverrides) ?? [:]
        let sfxEnabled = try container.decodeIfPresent([SoundEventKind: Bool].self, forKey: .sfxEnabled) ?? [:]
        let inputDasMs = try container.decodeIfPresent(Int.self, forKey: .inputDasMs) ?? 150
        let inputArrMs = try container.decodeIfPresent(Int.self, forKey: .inputArrMs) ?? 50
        let softDropArrMs = try container.decodeIfPresent(Int.self, forKey: .softDropArrMs) ?? 50

        self.volume = min(1.0, max(0.0, volume))
        self.muted = muted
        self.gainOverrides = gainOverrides.mapValues { min(1.0, max(0.0, $0)) }
        self.sfxEnabled = sfxEnabled
        self.inputDasMs = Self.clamp(inputDasMs, to: Self.inputDasRange)
        self.inputArrMs = Self.clamp(inputArrMs, to: Self.inputArrRange)
        self.softDropArrMs = Self.clamp(softDropArrMs, to: Self.softDropArrRange)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(volume, forKey: .volume)
        try container.encode(muted, forKey: .muted)
        try container.encode(gainOverrides, forKey: .gainOverrides)
        try container.encode(sfxEnabled, forKey: .sfxEnabled)
        try container.encode(inputDasMs, forKey: .inputDasMs)
        try container.encode(inputArrMs, forKey: .inputArrMs)
        try container.encode(softDropArrMs, forKey: .softDropArrMs)
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

    public func isSfxControlEnabled(for kind: SoundEventKind) -> Bool {
        isSfxEnabled(for: kind)
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
