import SwiftUI

public struct DiagnosticsView: View {
    public let state: DiagnosticsState

    public init(state: DiagnosticsState) {
        self.state = state
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(state.fpsText)
            Text(state.tickText)
        }
        .font(.system(size: 10, weight: .regular, design: .monospaced))
        .padding(6)
        .background(.black.opacity(0.5))
        .foregroundColor(.green)
        .cornerRadius(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding()
    }
}
