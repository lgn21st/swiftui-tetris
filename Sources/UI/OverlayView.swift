import SwiftUI

public struct OverlayView: View {
    public let state: OverlayState

    public init(state: OverlayState) {
        self.state = state
    }

    static func accessibilityLabel(for state: OverlayState) -> String {
        let title = state.title
        let message = state.message
        if title.isEmpty { return "" }
        var parts = [title]
        if !message.isEmpty {
            parts.append(message)
        }
        if !state.onboardingHints.isEmpty {
            parts.append(state.onboardingHints.joined(separator: " "))
        }
        return parts.joined(separator: ". ")
    }

    public var body: some View {
        if state.title.isEmpty {
            EmptyView()
        } else {
            ZStack {
                Color.black.opacity(ThemeConstants.overlayOpacity)
                VStack(spacing: LayoutConstants.overlaySpacing) {
                    Text(state.title)
                        .font(.system(size: TypographyConstants.overlayTitleSize, weight: .bold))
                        .foregroundColor(.white)
                    if !state.message.isEmpty {
                        if state.shouldBlinkStartHint {
                            BlinkingText(text: state.message)
                        } else {
                            Text(state.message)
                                .font(.system(size: TypographyConstants.overlayMessageSize, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    if !state.onboardingHints.isEmpty {
                        VStack(spacing: 4) {
                            ForEach(state.onboardingHints, id: \.self) { hint in
                                Text(hint)
                            }
                        }
                        .font(.system(size: TypographyConstants.overlayHintSize, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Self.accessibilityLabel(for: state))
            }
            .transition(.opacity)
        }
    }
}

private struct BlinkingText: View {
    let text: String
    @State private var visible = false

    var body: some View {
        Text(text)
            .font(.system(size: TypographyConstants.overlayMessageSize, weight: .medium))
            .foregroundColor(.white.opacity(0.85))
            .opacity(visible ? 1 : 0.15)
            .onAppear { visible = true }
            .animation(
                .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                value: visible
            )
    }
}
