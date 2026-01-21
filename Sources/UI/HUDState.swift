import Core

public struct HUDState: Equatable {
    public var scoreText: String
    public var levelText: String
    public var linesText: String
    public var holdText: String
    public var nextText: String

    public static func from(state: GameState) -> HUDState {
        let holdStatus = state.canHold ? "Ready" : "Used"
        let nextKind = state.nextQueue.first.map { "\($0)" } ?? "-"
        return HUDState(
            scoreText: "Score: \(state.score)",
            levelText: "Level: \(state.level)",
            linesText: "Lines: \(state.lines)",
            holdText: "Hold: \(holdStatus)",
            nextText: "Next: \(nextKind)"
        )
    }
}
