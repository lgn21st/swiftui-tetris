import SwiftUI
import Core

public struct SidePanelView: View {
    public let state: HUDState

    public init(state: HUDState) {
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.panelSectionSpacing) {
            VStack(alignment: .leading, spacing: 4) {
                Text(state.scoreText)
                Text(state.levelText)
                Text(state.linesText)
            }
            Divider().background(Color.white.opacity(ThemeConstants.dividerOpacity))
            VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                Text(state.statusText)
                    .foregroundColor(.white.opacity(0.85))
                Text(state.rulesetText)
                    .foregroundColor(.white.opacity(0.85))
            }
            Divider().background(Color.white.opacity(ThemeConstants.dividerOpacity))
            VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                Text("Hold")
                PreviewGridView(state: PreviewGridState.from(kind: state.holdKind))
                Text(state.holdText)
                    .font(.system(size: TypographyConstants.sidePanelHintFontSize, weight: .regular, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
            Divider().background(Color.white.opacity(ThemeConstants.dividerOpacity))
            VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                Text("Next")
                ForEach(Array(state.nextKinds.enumerated()), id: \.offset) { _, kind in
                    PreviewGridView(state: PreviewGridState.from(kind: kind), cellSize: 10)
                }
            }
            Divider().background(Color.white.opacity(ThemeConstants.dividerOpacity))
            Text(state.comboText)
            Text(state.b2bText)
            ProgressView(value: state.lockBarRatio)
                .tint(state.lockWarningActive ? .red : .green)
            Text(state.hintText)
                .font(.system(size: TypographyConstants.sidePanelHintFontSize, weight: .regular, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
        }
        .font(.system(size: TypographyConstants.sidePanelFontSize, weight: .medium, design: .monospaced))
        .foregroundColor(.white)
        .padding(LayoutConstants.panelPadding)
        .frame(width: LayoutConstants.panelWidth, height: LayoutConstants.baseSize.height)
        .background(Color.black.opacity(ThemeConstants.panelOpacity))
        .cornerRadius(LayoutConstants.panelCornerRadius)
        .shadow(
            color: .black.opacity(ThemeConstants.panelShadowOpacity),
            radius: LayoutConstants.panelShadowRadius,
            x: 0,
            y: 4
        )
    }
}
