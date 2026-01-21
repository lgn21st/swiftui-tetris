import Core

public enum SoundEventKind: String, CaseIterable, Identifiable {
    case move
    case rotate
    case softDrop
    case hardDrop
    case hold
    case lineClear
    case gameOver

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .move: return "Move"
        case .rotate: return "Rotate"
        case .softDrop: return "Soft Drop"
        case .hardDrop: return "Hard Drop"
        case .hold: return "Hold"
        case .lineClear: return "Line Clear"
        case .gameOver: return "Game Over"
        }
    }

    public static func from(event: SoundEvent) -> SoundEventKind {
        switch event {
        case .move: return .move
        case .rotate: return .rotate
        case .softDrop: return .softDrop
        case .hardDrop: return .hardDrop
        case .hold: return .hold
        case .lineClear: return .lineClear
        case .gameOver: return .gameOver
        }
    }
}
