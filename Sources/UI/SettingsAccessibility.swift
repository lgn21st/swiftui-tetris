public enum SettingsAccessibility {
    public static let volumeLabel = "Volume"

    public static func sfxLabel(for kind: SoundEventKind) -> String {
        "\(kind.label) SFX"
    }
}
