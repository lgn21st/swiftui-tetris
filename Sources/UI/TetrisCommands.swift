import SwiftUI

public struct TetrisCommands: Commands {
    @FocusedValue(\.commandActions) private var actions

    public init() {}

    public var body: some Commands {
        CommandMenu("Game") {
            Button("Start") {
                actions?.startGame()
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .disabled(actions == nil)

            Button("Restart") {
                actions?.restartGame()
            }
            .keyboardShortcut("r", modifiers: [.command])
            .disabled(actions == nil)

            Button("Pause / Resume") {
                actions?.togglePause()
            }
            .keyboardShortcut("p", modifiers: [.command])
            .disabled(actions == nil)

            Button("Settings") {
                actions?.toggleSettings()
            }
            .keyboardShortcut(",", modifiers: [.command])
            .disabled(actions == nil)
        }
    }
}
