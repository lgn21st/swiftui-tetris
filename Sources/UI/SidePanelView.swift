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
                Text(state.scoreText)
                Text(state.levelText)
                Text(state.linesText)
                Text(state.statusText)
                Text(state.rulesetText)
                Text(state.holdText)
            }
            let warningOpacity = 0.35 + 0.65 * state.lockWarningPulse
            let warningColor = Color.red.opacity(warningOpacity)
            let normalColor = Color.green.opacity(0.7)
            PanelDivider()
            ProgressView(value: state.lockBarRatio)
                .tint(state.lockWarningActive ? warningColor : normalColor)
            PanelDivider()
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: LayoutConstants.panelSectionSpacing) {
                VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                    Text("Hold")
                        .font(.system(size: TypographyConstants.sidePanelSectionFontSize, weight: .semibold, design: .default))
                    PreviewGridView(state: PreviewGridState.from(kind: state.holdKind))
                }
                PanelDivider()
                VStack(alignment: .leading, spacing: LayoutConstants.panelItemSpacing) {
                    let paddedNextKinds: [TetrominoType?] = {
                        let base = state.nextKinds.map { Optional($0) }
                        if base.count >= 3 { return Array(base.prefix(3)) }
                        return base + Array(repeating: nil, count: 3 - base.count)
                    }()
                    Text("Next")
                        .font(.system(size: TypographyConstants.sidePanelSectionFontSize, weight: .semibold, design: .default))
                    HStack(spacing: LayoutConstants.panelItemSpacing) {
                        ForEach(0..<paddedNextKinds.count, id: \.self) { index in
                            PreviewGridView(
                                state: PreviewGridState.from(kind: paddedNextKinds[index]),
                                cellSize: 10
                            )
                        }
                    }
                }
            }
        }
        .font(.system(size: TypographyConstants.sidePanelFontSize, weight: .semibold, design: .default))
        .monospacedDigit()
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

private struct PanelDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                Color(
                    red: ThemeConstants.borderColorRed,
                    green: ThemeConstants.borderColorGreen,
                    blue: ThemeConstants.borderColorBlue
                )
                .opacity(ThemeConstants.dividerOpacity)
            )
            .frame(height: LayoutConstants.panelDividerHeight)
            .padding(.vertical, LayoutConstants.panelDividerPadding)
    }
}
