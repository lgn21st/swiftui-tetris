import SwiftUI

public struct TetrisCommands: Commands {
    @FocusedValue(\.commandActions) private var actions

    public init() {}

    public var body: some Commands {
        CommandMenu("Game") {
            Button("Restart") {
                actions?.restartGame()
            }
            .disabled(actions == nil)

            Button("Pause / Resume") {
                actions?.togglePause()
            }
            .disabled(actions == nil)

            Button("Toggle Diagnostics") {
                actions?.toggleDiagnostics()
            }
            .disabled(actions == nil)

            Button("Toggle Full Screen") {
                actions?.toggleFullScreen()
            }
            .disabled(actions == nil)
            .keyboardShortcut("f", modifiers: [.control, .command])
        }
    }
}
