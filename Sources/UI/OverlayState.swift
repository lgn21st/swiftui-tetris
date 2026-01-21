public struct OverlayState: Equatable {
    public var isPaused: Bool
    public var isGameOver: Bool
    public var isTitle: Bool

    public var title: String {
        if isGameOver { return "Game Over" }
        if isPaused { return "Paused" }
        if isTitle { return "Title" }
        return ""
    }
}
