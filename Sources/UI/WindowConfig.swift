import Foundation

public enum WindowConfig {
    public static let defaultWidth: CGFloat = 480
    public static let defaultHeight: CGFloat = 720
    public static let minScale: CGFloat = 0.6
    public static let minWidth: CGFloat = defaultWidth * minScale
    public static let minHeight: CGFloat = defaultHeight * minScale
    public static let allowsResize: Bool = true
}
