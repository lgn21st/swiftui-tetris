import Core

public struct FocusPauseHandler {
    public init() {}

    public func handleAppActiveChanged(
        isActive: Bool,
        state: inout GameState,
        input: InputEngine,
        started: Bool,
        showSettings: Bool
    ) -> OverlayState {
        guard !isActive else {
            return OverlayState(
                isPaused: state.paused || showSettings,
                isGameOver: state.gameOver,
                isTitle: !started,
                isSettings: showSettings
            )
        }
        state.paused = true
        input.reset()
        return OverlayState(
            isPaused: true,
            isGameOver: state.gameOver,
            isTitle: !started,
            isSettings: showSettings
        )
    }
}
