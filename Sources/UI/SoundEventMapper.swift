import Core

public enum SoundEventMapper {
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
}
