public enum SettingsAccessibility {
    public static let volumeLabel = "Volume"
    public static let inputDasLabel = "DAS (ms)"
    public static let inputArrLabel = "ARR (ms)"
    public static let softDropArrLabel = "Soft Drop ARR (ms)"
    public static let resetLabel = "Reset Settings"
    public static let closeLabel = "Close Settings"

    public static func sfxLabel(for kind: SoundEventKind) -> String {
        "\(kind.label) SFX"
    }

    public static func sfxToggleLabel(for kind: SoundEventKind) -> String {
        "\(kind.label) SFX Enabled"
    }
}
