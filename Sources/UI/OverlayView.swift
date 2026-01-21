import SwiftUI

public struct OverlayView: View {
    public let state: OverlayState

    public init(state: OverlayState) {
        self.state = state
    }

    public var body: some View {
        if state.title.isEmpty {
            EmptyView()
        } else {
            ZStack {
                Color.black.opacity(0.5)
                VStack(spacing: 8) {
                    Text(state.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    if !state.message.isEmpty {
                        Text(state.message)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}
