import SwiftUI
import Core

public struct SidePanelView: View {
    public let state: HUDState

    public init(state: HUDState) {
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.panelSectionSpacing) {
            VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                Text(state.lastInputText)
                Text(state.scoreText)
                Text(state.levelText)
                Text(state.linesText)
                Text(state.statusText)
                Text(state.rulesetText)
                Text(state.holdText)
                Text(state.groundedText)
                Text(state.lockResetsText)
                Text(state.sfxText)
                if !state.isClassicRuleset {
                    VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                        Text(state.comboText)
                        Text(state.b2bText)
                    }
                }
            }
            let warningOpacity = 0.35 + 0.65 * state.lockWarningPulse
            let warningColor = Color.red.opacity(warningOpacity)
            let normalColor = Color.green.opacity(0.7)
            ProgressView(value: state.lockBarRatio)
                .tint(state.lockWarningActive ? warningColor : normalColor)
            VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                Text("Hold")
                    .font(.system(size: TypographyConstants.sidePanelSectionFontSize, weight: .semibold, design: .monospaced))
                PreviewGridView(state: PreviewGridState.from(kind: state.holdKind))
            }
            VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                Text("Next")
                    .font(.system(size: TypographyConstants.sidePanelSectionFontSize, weight: .semibold, design: .monospaced))
                ForEach(Array(state.nextKinds.enumerated()), id: \.offset) { _, kind in
                    PreviewGridView(state: PreviewGridState.from(kind: kind), cellSize: 10)
                }
            }
            Spacer()
        }
        .font(.system(size: TypographyConstants.sidePanelFontSize, weight: .medium, design: .monospaced))
        .foregroundColor(
            Color(
                red: ThemeConstants.panelTextRed,
                green: ThemeConstants.panelTextGreen,
                blue: ThemeConstants.panelTextBlue
            )
        )
        .padding(LayoutConstants.panelPadding)
        .frame(width: LayoutConstants.panelWidth, height: LayoutConstants.boardHeight)
        .background(
            Color(
                red: ThemeConstants.panelBackgroundRed,
                green: ThemeConstants.panelBackgroundGreen,
                blue: ThemeConstants.panelBackgroundBlue
            )
        )
        .overlay(
            Rectangle().stroke(
                Color(
                    red: ThemeConstants.borderColorRed,
                    green: ThemeConstants.borderColorGreen,
                    blue: ThemeConstants.borderColorBlue,
                    opacity: ThemeConstants.panelBorderOpacity
                ),
                lineWidth: LayoutConstants.panelBorderWidth
            )
        )
        .shadow(
            color: .black.opacity(ThemeConstants.panelShadowOpacity),
            radius: LayoutConstants.panelShadowRadius,
            x: 0,
            y: 4
        )
    }
}
