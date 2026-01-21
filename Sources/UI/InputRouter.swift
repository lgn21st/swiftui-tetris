import Core

public enum InputRouter {
    public static func action(forKey key: String) -> GameAction? {
        KeyMapper.action(for: key.lowercased())
    }

    public static func action(forButton button: GamepadButton) -> GameAction? {
        GamepadMapping.action(for: button)
    }
}
