import Core

public struct HUDState: Equatable {
    public var scoreText: String
    public var levelText: String
    public var linesText: String
    public var holdText: String
    public var nextText: String
    public var comboText: String
    public var b2bText: String
    public var lockBarRatio: Double
    public var lockWarningActive: Bool
    public var hintText: String
    public var holdKind: TetrominoType?
    public var nextKinds: [TetrominoType]

    private static let lockWarningThreshold = 0.85
    private static let defaultHint = "Keys: ←/→ Move · ↑ Rotate · ↓ Soft · Space Hard · C Hold · P Pause"

    public static func from(state: GameState) -> HUDState {
        let holdStatus = state.canHold ? "Ready" : "Used"
        let nextKind = state.nextQueue.first.map { "\($0)" } ?? "-"
        let comboText = state.combo >= 0 ? "Combo: \(state.combo)" : "Combo: -"
        let b2bText = "B2B: \(state.backToBack ? "Yes" : "No")"
        let ratio = state.config.lockDelayMs == 0 ? 0 : Double(state.lockTimerMs) / Double(state.config.lockDelayMs)
        let clampedRatio = min(max(ratio, 0), 1)
        return HUDState(
            scoreText: "Score: \(state.score)",
            levelText: "Level: \(state.level)",
            linesText: "Lines: \(state.lines)",
            holdText: "Hold: \(holdStatus)",
            nextText: "Next: \(nextKind)",
            comboText: comboText,
            b2bText: b2bText,
            lockBarRatio: clampedRatio,
            lockWarningActive: clampedRatio >= lockWarningThreshold,
            hintText: defaultHint,
            holdKind: state.hold,
            nextKinds: Array(state.nextQueue.prefix(5))
        )
    }
}
