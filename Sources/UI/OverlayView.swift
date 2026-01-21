import SwiftUI

public struct OverlayView: View {
    public let state: OverlayState

    public init(state: OverlayState) {
        self.state = state
    }

    static func showsContent(for state: OverlayState) -> Bool {
        !state.isSettings
    }

    static func accessibilityLabel(for state: OverlayState) -> String {
        if !showsContent(for: state) { return "" }
        let title = state.title
        let message = state.message
        if title.isEmpty { return "" }
        if message.isEmpty { return title }
        return "\(title). \(message)"
    }

    public var body: some View {
        if state.title.isEmpty {
            EmptyView()
        } else {
            ZStack {
                Color.black.opacity(ThemeConstants.overlayOpacity)
                if Self.showsContent(for: state) {
                    VStack(spacing: LayoutConstants.overlaySpacing) {
                        Text(state.title)
                            .font(.system(size: TypographyConstants.overlayTitleSize, weight: .bold))
                            .foregroundColor(.white)
                        if !state.message.isEmpty {
                            Text(state.message)
                                .font(.system(size: TypographyConstants.overlayMessageSize, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Self.accessibilityLabel(for: state))
                }
            }
            .transition(.opacity)
        }
    }
}
