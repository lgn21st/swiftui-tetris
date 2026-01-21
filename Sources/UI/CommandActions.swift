import SwiftUI

public struct CommandActions {
    public let startGame: () -> Void
    public let restartGame: () -> Void
    public let togglePause: () -> Void
    public let toggleSettings: () -> Void

    public init(
        startGame: @escaping () -> Void,
        restartGame: @escaping () -> Void,
        togglePause: @escaping () -> Void,
        toggleSettings: @escaping () -> Void
    ) {
        self.startGame = startGame
        self.restartGame = restartGame
        self.togglePause = togglePause
        self.toggleSettings = toggleSettings
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
