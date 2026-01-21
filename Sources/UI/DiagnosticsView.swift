import SwiftUI

public struct DiagnosticsView: View {
    public let state: DiagnosticsState
    public let hudState: HUDDiagnosticsState?

    public init(state: DiagnosticsState, hudState: HUDDiagnosticsState? = nil) {
        self.state = state
        self.hudState = hudState
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 4) {
                Text(state.fpsText)
                Text(state.tickText)
            }
            if let hudState {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text(hudState.lastInputText)
                    Text(hudState.groundedText)
                    Text(hudState.lockResetsText)
                    if !hudState.isClassicRuleset {
                        Text(hudState.comboText)
                        Text(hudState.b2bText)
                    }
                    Text(hudState.hintText)
                }
            }
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
