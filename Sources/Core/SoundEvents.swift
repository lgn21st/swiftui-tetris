public enum SoundEvent: Equatable {
    case move
    case rotate
    case softDrop
    case hardDrop
    case lineClear(Int)
    case gameOver
    case hold
}
