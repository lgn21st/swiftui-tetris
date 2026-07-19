import Core

public struct FocusPauseHandler {
    public init() {}

    public func handleAppActiveChanged(
        isActive: Bool,
        snapshot: GameStateSnapshot,
        input: InputEngine,
        started: Bool
    ) -> OverlayState {
        guard !isActive else {
            return OverlayState(
                isPaused: snapshot.paused,
                isGameOver: snapshot.gameOver,
                isTitle: !started,
                onboardingHints: !started ? OverlayState.defaultOnboardingHints : []
            )
        }
        input.reset()
        return OverlayState(
            isPaused: snapshot.paused,
            isGameOver: snapshot.gameOver,
            isTitle: !started,
            onboardingHints: !started ? OverlayState.defaultOnboardingHints : []
        )
    }
}
