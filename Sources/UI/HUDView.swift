import SwiftUI

public struct HUDView: View {
    public let state: HUDState
    @State private var pulseOn = false

    public init(state: HUDState) {
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(state.scoreText)
            Text(state.levelText)
            Text(state.linesText)
            Text(state.holdText)
            Text(state.nextText)
            Text(state.comboText)
            Text(state.b2bText)
            ProgressView(value: state.lockBarRatio)
                .tint(state.lockWarningActive ? .red : .green)
                .opacity(state.lockWarningActive ? (pulseOn ? 1.0 : 0.4) : 1.0)
                .onAppear {
                    if state.lockWarningActive {
                        pulseOn = true
                    }
                }
                .onChange(of: state.lockWarningActive) { active in
                    pulseOn = active
                }
                .animation(
                    state.lockWarningActive
                    ? .easeInOut(duration: 0.4).repeatForever(autoreverses: true)
                    : .default,
                    value: pulseOn
                )
            Text(state.hintText)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
        }
        .font(.system(size: 12, weight: .medium, design: .monospaced))
        .padding(8)
        .background(.black.opacity(0.4))
        .foregroundColor(.white)
        .cornerRadius(6)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
