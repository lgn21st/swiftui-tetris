import SwiftUI
import Core

public struct SidePanelView: View {
    public let state: HUDState

    public init(state: HUDState) {
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(state.scoreText)
                Text(state.levelText)
                Text(state.linesText)
            }
            Divider().background(Color.white.opacity(ThemeConstants.dividerOpacity))
            VStack(alignment: .leading, spacing: 6) {
                Text("Hold")
                PreviewGridView(state: PreviewGridState.from(kind: state.holdKind))
                Text(state.holdText)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
            Divider().background(Color.white.opacity(ThemeConstants.dividerOpacity))
            VStack(alignment: .leading, spacing: 6) {
                Text("Next")
                ForEach(Array(state.nextKinds.enumerated()), id: \.offset) { _, kind in
                    PreviewGridView(state: PreviewGridState.from(kind: kind), cellSize: 10)
                }
            }
            Divider().background(Color.white.opacity(ThemeConstants.dividerOpacity))
            Text(state.comboText)
            Text(state.b2bText)
            Text(state.statusText)
            Text(state.rulesetText)
            ProgressView(value: state.lockBarRatio)
                .tint(state.lockWarningActive ? .red : .green)
            Text(state.hintText)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
        }
        .font(.system(size: 12, weight: .medium, design: .monospaced))
        .foregroundColor(.white)
        .padding(LayoutConstants.panelPadding)
        .frame(width: LayoutConstants.panelWidth, height: LayoutConstants.baseSize.height)
        .background(Color.black.opacity(ThemeConstants.panelOpacity))
    }
}
