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
                Text(state.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .ignoresSafeArea()
        }
    }
}
