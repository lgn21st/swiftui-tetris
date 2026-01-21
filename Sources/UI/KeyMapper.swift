import Core

public enum KeyMapper {
    public static func action(for key: String) -> GameAction? {
        switch key {
        case "escape": return .pause
        case "left": return .moveLeft
        case "right": return .moveRight
        case "down": return .softDrop
        case "up": return .rotateCw
        case " ", "space": return .hardDrop
        case "c": return .hold
        case "p": return .pause
        case "r": return .restart
        default: return nil
        }
    }
}
