public enum SettingsAccessibility {
    public static let volumeLabel = "Volume"
    public static let resetLabel = "Reset Settings"
    public static let closeLabel = "Close Settings"

    public static func sfxLabel(for kind: SoundEventKind) -> String {
        "\(kind.label) SFX"
    }
}
