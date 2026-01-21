import Foundation
import Core

public struct HUDState: Equatable {
    public var lastInputText: String
    public var scoreText: String
    public var levelText: String
    public var linesText: String
    public var holdText: String
    public var nextText: String
    public var groundedText: String
    public var lockResetsText: String
    public var sfxText: String
    public var comboText: String
    public var b2bText: String
    public var statusText: String
    public var rulesetText: String
    public var lockBarRatio: Double
    public var lockWarningActive: Bool
    public var lockWarningPulse: Double
    public var hintText: String
    public var holdKind: TetrominoType?
    public var nextKinds: [TetrominoType]
    public var isClassicRuleset: Bool

    private static let lockWarningThreshold = 0.85
    private static let lockWarningPulsePeriodMs = 400
    private static let lockWarningPulseMin = 0.4
    private static let lockWarningPulseMax = 1.0
    private static let defaultHint = "Keys: ←/→ Move · ↑ Rotate · ↓ Soft · Space Hard · C Hold · P Pause · S Settings · M Mute"

    public static func from(
        state: GameState,
        started: Bool = true,
        settings: SettingsState = SettingsState(),
        lastInput: GameAction? = nil
    ) -> HUDState {
        let holdStatus = state.canHold ? "Ready" : "Used"
        let nextKind = state.nextQueue.first.map { "\($0)" } ?? "-"
        let comboText = state.combo >= 0 ? "Combo: \(state.combo)" : "Combo: -"
        let b2bText = "B2B: \(state.backToBack ? "Yes" : "No")"
        let statusText: String
        if state.gameOver {
            statusText = "Status: Game Over"
        } else if state.paused {
            statusText = "Status: Paused"
        } else if !started {
            statusText = "Status: Ready"
        } else {
            statusText = "Status: Playing"
        }
        let isClassicRuleset = state.config.ruleset == .classic
        let rulesetText = "Rules: \(isClassicRuleset ? "Classic" : "Modern")"
        let ratio = state.config.lockDelayMs == 0 ? 0 : Double(state.lockTimerMs) / Double(state.config.lockDelayMs)
        let clampedRatio = min(max(ratio, 0), 1)
        let groundedText = "Grounded: \(state.canMoveDown() ? "No" : "Yes")"
        let remainingResets = max(state.config.lockResetLimit - state.lockResetCount, 0)
        let lockResetsText = "Lock resets: \(remainingResets)/\(state.config.lockResetLimit)"
        let lastInputText = "Last input: \(formatLastInput(lastInput))"
        let sfxText = "SFX: \(formatSfx(settings))"
        let lockWarningActive = clampedRatio >= lockWarningThreshold
        let lockWarningPulse = lockWarningPulseValue(
            lockTimerMs: state.lockTimerMs,
            isWarning: lockWarningActive
        )
        return HUDState(
            lastInputText: lastInputText,
            scoreText: "Score: \(state.score)",
            levelText: "Level: \(state.level)",
            linesText: "Lines: \(state.lines)",
            holdText: "Hold: \(holdStatus)",
            nextText: "Next: \(nextKind)",
            groundedText: groundedText,
            lockResetsText: lockResetsText,
            sfxText: sfxText,
            comboText: comboText,
            b2bText: b2bText,
            statusText: statusText,
            rulesetText: rulesetText,
            lockBarRatio: clampedRatio,
            lockWarningActive: lockWarningActive,
            lockWarningPulse: lockWarningPulse,
            hintText: defaultHint,
            holdKind: state.hold,
            nextKinds: Array(state.nextQueue.prefix(1)),
            isClassicRuleset: isClassicRuleset
        )
    }

    private static func formatLastInput(_ action: GameAction?) -> String {
        guard let action else { return "None" }
        switch action {
        case .moveLeft:
            return "Left"
        case .moveRight:
            return "Right"
        case .softDrop:
            return "Soft Drop"
        case .hardDrop:
            return "Hard Drop"
        case .rotateCw:
            return "Rotate CW"
        case .rotateCcw:
            return "Rotate CCW"
        case .hold:
            return "Hold"
        case .pause:
            return "Pause"
        case .restart:
            return "Restart"
        }
    }

    private static func formatSfx(_ settings: SettingsState) -> String {
        if settings.muted {
            return "Muted"
        }
        return String(format: "%.0f%%", settings.volume * 100.0)
    }

    private static func lockWarningPulseValue(lockTimerMs: Int, isWarning: Bool) -> Double {
        guard isWarning else { return 0 }
        let period = max(lockWarningPulsePeriodMs, 1)
        let phase = Double(lockTimerMs % period) / Double(period)
        let triangle = phase < 0.5 ? phase * 2 : (1 - phase) * 2
        return lockWarningPulseMin + (lockWarningPulseMax - lockWarningPulseMin) * triangle
    }
}
