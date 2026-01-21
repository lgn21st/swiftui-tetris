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

    public var message: String {
        if isGameOver { return "Press R to restart" }
        if isPaused { return "Press P to resume · R to restart" }
        if isTitle { return "Press Space or Enter to start" }
        return ""
    }
}
