import SwiftUI

public struct CommandActions {
    public let startGame: () -> Void
    public let restartGame: () -> Void
    public let togglePause: () -> Void
    public let toggleDiagnostics: () -> Void
    public let toggleFullScreen: () -> Void

    public init(
        startGame: @escaping () -> Void,
        restartGame: @escaping () -> Void,
        togglePause: @escaping () -> Void,
        toggleDiagnostics: @escaping () -> Void,
        toggleFullScreen: @escaping () -> Void
    ) {
        self.startGame = startGame
        self.restartGame = restartGame
        self.togglePause = togglePause
        self.toggleDiagnostics = toggleDiagnostics
        self.toggleFullScreen = toggleFullScreen
    }
}

private struct CommandActionsKey: FocusedValueKey {
    typealias Value = CommandActions
}

public extension FocusedValues {
    var commandActions: CommandActions? {
        get { self[CommandActionsKey.self] }
        set { self[CommandActionsKey.self] = newValue }
    }
}
