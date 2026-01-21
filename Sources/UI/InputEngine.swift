import Core

public final class InputEngine {
    public init() {}

    public func apply(action: GameAction, to state: inout GameState) {
        state.apply(action: action)
    }
}
