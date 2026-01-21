import Core

public enum SoundEventMapper {
    public static let allFileNames: [String] = [
        "move.wav",
        "rotate.wav",
        "soft_drop.wav",
        "hard_drop.wav",
        "hold.wav",
        "line_clear_1.wav",
        "line_clear_2.wav",
        "line_clear_3.wav",
        "line_clear_4.wav",
        "game_over.wav"
    ]

    public static func fileName(for event: SoundEvent) -> String? {
        switch event {
        case .move: return "move.wav"
        case .rotate: return "rotate.wav"
        case .softDrop: return "soft_drop.wav"
        case .hardDrop: return "hard_drop.wav"
        case .hold: return "hold.wav"
        case .lineClear(let count): return "line_clear_\(count).wav"
        case .gameOver: return "game_over.wav"
        }
    }

    public static func gain(for event: SoundEvent) -> Double {
        switch event {
        case .move: return 0.2
        case .rotate: return 0.3
        case .softDrop: return 0.2
        case .hardDrop: return 0.4
        case .hold: return 0.35
        case .lineClear(let count): return min(0.5 + (0.1 * Double(count - 1)), 0.8)
        case .gameOver: return 0.6
        }
    }

    public static func gain(for kind: SoundEventKind) -> Double {
        switch kind {
        case .move: return 0.2
        case .rotate: return 0.3
        case .softDrop: return 0.2
        case .hardDrop: return 0.4
        case .hold: return 0.35
        case .lineClear: return 0.5
        case .gameOver: return 0.6
        }
    }
}
