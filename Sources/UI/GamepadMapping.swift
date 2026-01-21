import Core

public enum GamepadButton: CaseIterable {
    case buttonA
    case buttonB
    case buttonX
    case buttonY
    case leftShoulder
    case rightShoulder
    case menu
    case options
    case dpadUp
}

public enum GamepadMapping {
    public static func action(for button: GamepadButton) -> GameAction? {
        switch button {
        case .buttonA: return .rotateCw
        case .buttonB: return .rotateCcw
        case .buttonX: return .hardDrop
        case .buttonY: return .hold
        case .leftShoulder: return .rotateCcw
        case .rightShoulder: return .rotateCw
        case .menu: return .pause
        case .options: return .restart
        case .dpadUp: return .rotateCw
        }
    }
}
