public struct OverlayState: Equatable {
    public var isPaused: Bool
    public var isGameOver: Bool
    public var isTitle: Bool
    public var isSettings: Bool

    public var title: String {
        if isGameOver { return "Game Over" }
        if isSettings { return "Settings" }
        if isPaused { return "Paused" }
        if isTitle { return "Title" }
        return ""
    }

    public var message: String {
        if isGameOver { return "Press R to restart" }
        if isSettings { return "S or Esc to close, M mute, +/- volume, 0 reset" }
        if isPaused { return "Press P to resume, R to restart" }
        if isTitle { return "Press Space or Enter to start" }
        return ""
    }
}
