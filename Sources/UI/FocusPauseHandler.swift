import Core

public struct FocusPauseHandler {
    public init() {}

    public func handleAppActiveChanged(
        isActive: Bool,
        state: inout GameState,
        input: InputEngine,
        started: Bool
    ) -> OverlayState {
        guard !isActive else {
            return OverlayState(
                isPaused: state.paused,
                isGameOver: state.gameOver,
                isTitle: !started,
                onboardingHints: !started ? OverlayState.defaultOnboardingHints : []
            )
        }
        input.reset()
        return OverlayState(
            isPaused: state.paused,
            isGameOver: state.gameOver,
            isTitle: !started,
            onboardingHints: !started ? OverlayState.defaultOnboardingHints : []
        )
    }
}
