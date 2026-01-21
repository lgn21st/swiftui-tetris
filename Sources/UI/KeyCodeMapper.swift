import Foundation

public enum KeyCodeMapper {
    public static func keyString(for keyCode: UInt16) -> String? {
        switch keyCode {
        case 123: return "left"
        case 124: return "right"
        case 125: return "down"
        case 126: return "up"
        default: return nil
        }
    }
}
