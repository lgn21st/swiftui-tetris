import SwiftUI

public struct SettingsView: View {
    @Binding public var settings: SettingsState

    public init(settings: Binding<SettingsState>) {
        self._settings = settings
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.settingsSpacing) {
            Text("Settings")
                .font(.system(size: TypographyConstants.settingsTitleSize, weight: .bold))
            Toggle("Mute", isOn: Binding(
                get: { settings.muted },
                set: { _ in settings.toggleMute() }
            ))
            HStack {
                Text("Volume")
                Slider(value: Binding(
                    get: { settings.volume },
                    set: { settings.volume = $0 }
                ), in: 0...1)
            }
            Divider().background(Color.white.opacity(0.4))
            Text("SFX Levels")
                .font(.system(size: TypographyConstants.settingsSectionSize, weight: .semibold))
            ForEach(SoundEventKind.allCases) { kind in
                HStack {
                    Text(kind.label)
                        .frame(width: 90, alignment: .leading)
                    Slider(value: Binding(
                        get: { settings.gainOverrides[kind] ?? SoundEventMapper.gain(for: kind) },
                        set: { settings.setGain($0, for: kind) }
                    ), in: 0...1)
                }
            }
            Button("Reset") { settings.reset() }
        }
        .font(.system(size: TypographyConstants.sidePanelFontSize, weight: .medium, design: .monospaced))
        .padding(12)
        .background(.black.opacity(ThemeConstants.panelOpacity))
        .foregroundColor(.white)
        .cornerRadius(LayoutConstants.panelCornerRadius)
        .shadow(
            color: .black.opacity(ThemeConstants.panelShadowOpacity),
            radius: LayoutConstants.panelShadowRadius,
            x: 0,
            y: 4
        )
        .frame(maxWidth: LayoutConstants.settingsMaxWidth)
    }
}
