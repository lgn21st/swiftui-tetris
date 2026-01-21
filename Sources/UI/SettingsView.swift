import SwiftUI

public struct SettingsView: View {
    @Binding public var settings: SettingsState

    public init(settings: Binding<SettingsState>) {
        self._settings = settings
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.system(size: 18, weight: .bold))
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
            Button("Reset") { settings.reset() }
        }
        .padding(12)
        .background(.black.opacity(0.6))
        .foregroundColor(.white)
        .cornerRadius(8)
        .frame(maxWidth: 260)
    }
}
