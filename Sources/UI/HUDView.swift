import SwiftUI

public struct HUDView: View {
    public let state: HUDState

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
