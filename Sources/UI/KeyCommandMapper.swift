import AppKit

public enum KeyCommandMapper {
    public static func isFullScreenToggle(key: String, modifiers: NSEvent.ModifierFlags) -> Bool {
        let normalized = key.lowercased()
        return modifiers.contains(.command)
            && modifiers.contains(.control)
            && normalized == "f"
    }
}
