import SwiftUI

public struct CommandActions {
    public let startGame: () -> Void
    public let restartGame: () -> Void
    public let togglePause: () -> Void

    public init(
        startGame: @escaping () -> Void,
        restartGame: @escaping () -> Void,
        togglePause: @escaping () -> Void
    ) {
        self.startGame = startGame
        self.restartGame = restartGame
        self.togglePause = togglePause
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
