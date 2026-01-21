import SwiftUI

public struct SettingsView: View {
    @Binding public var settings: SettingsState
    public var onClose: () -> Void
    @FocusState private var focusedField: SettingsFocusField?

    public init(settings: Binding<SettingsState>, onClose: @escaping () -> Void) {
        self._settings = settings
        self.onClose = onClose
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.settingsSpacing) {
            Text("Settings")
                .font(.system(size: TypographyConstants.settingsTitleSize, weight: .bold))
            Toggle("Mute", isOn: Binding(
                get: { settings.muted },
                set: { _ in settings.toggleMute() }
            ))
            .focused($focusedField, equals: SettingsFocusPolicy.defaultField)
            HStack {
                Text("Volume")
                Slider(value: Binding(
                    get: { settings.volume },
                    set: { settings.volume = $0 }
                ), in: 0...1)
                .accessibilityLabel(SettingsAccessibility.volumeLabel)
            }
            Divider().background(Color.white.opacity(0.4))
            Text("Input Repeat")
                .font(.system(size: TypographyConstants.settingsSectionSize, weight: .semibold))
            HStack {
                Text("DAS")
                    .frame(width: 90, alignment: .leading)
                Slider(value: Binding(
                    get: { Double(settings.inputDasMs) },
                    set: { settings.setInputDas(Int($0.rounded())) }
                ), in: Double(SettingsState.inputDasRange.lowerBound)...Double(SettingsState.inputDasRange.upperBound))
                .accessibilityLabel(SettingsAccessibility.inputDasLabel)
                Text("\(settings.inputDasMs) ms")
                    .frame(width: 70, alignment: .trailing)
            }
            HStack {
                Text("ARR")
                    .frame(width: 90, alignment: .leading)
                Slider(value: Binding(
                    get: { Double(settings.inputArrMs) },
                    set: { settings.setInputArr(Int($0.rounded())) }
                ), in: Double(SettingsState.inputArrRange.lowerBound)...Double(SettingsState.inputArrRange.upperBound))
                .accessibilityLabel(SettingsAccessibility.inputArrLabel)
                Text("\(settings.inputArrMs) ms")
                    .frame(width: 70, alignment: .trailing)
            }
            HStack {
                Text("Soft ARR")
                    .frame(width: 90, alignment: .leading)
                Slider(value: Binding(
                    get: { Double(settings.softDropArrMs) },
                    set: { settings.setSoftDropArr(Int($0.rounded())) }
                ), in: Double(SettingsState.softDropArrRange.lowerBound)...Double(SettingsState.softDropArrRange.upperBound))
                .accessibilityLabel(SettingsAccessibility.softDropArrLabel)
                Text("\(settings.softDropArrMs) ms")
                    .frame(width: 70, alignment: .trailing)
            }
            Divider().background(Color.white.opacity(0.4))
            Text("SFX Levels")
                .font(.system(size: TypographyConstants.settingsSectionSize, weight: .semibold))
            ForEach(SoundEventKind.allCases) { kind in
                HStack {
                    Text(kind.label)
                        .frame(width: 90, alignment: .leading)
                    Toggle(isOn: Binding(
                        get: { settings.isSfxEnabled(for: kind) },
                        set: { settings.setSfxEnabled($0, for: kind) }
                    )) {
                        Text("Enabled")
                    }
                    .labelsHidden()
                    .accessibilityLabel(SettingsAccessibility.sfxToggleLabel(for: kind))
                    Slider(value: Binding(
                        get: { settings.gainOverrides[kind] ?? SoundEventMapper.gain(for: kind) },
                        set: { settings.setGain($0, for: kind) }
                    ), in: 0...1)
                    .accessibilityLabel(SettingsAccessibility.sfxLabel(for: kind))
                    .disabled(!settings.isSfxControlEnabled(for: kind))
                }
                .opacity(settings.isSfxControlEnabled(for: kind) ? 1.0 : 0.6)
            }
            HStack(spacing: LayoutConstants.settingsSpacing) {
                Button("Reset") { settings.reset() }
                    .accessibilityLabel(SettingsAccessibility.resetLabel)
                Button("Close") { onClose() }
                    .keyboardShortcut("s")
                    .accessibilityLabel(SettingsAccessibility.closeLabel)
            }
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
        .onAppear {
            focusedField = SettingsFocusPolicy.defaultField
        }
        .onExitCommand {
            onClose()
        }
    }
}
