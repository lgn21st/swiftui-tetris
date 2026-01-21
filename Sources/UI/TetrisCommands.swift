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
        }
    }
}
