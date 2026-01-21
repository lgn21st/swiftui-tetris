import CoreGraphics

public struct WindowState: Codable, Equatable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public init(frame: CGRect) {
        self.init(
            x: Double(frame.origin.x),
            y: Double(frame.origin.y),
            width: Double(frame.size.width),
            height: Double(frame.size.height)
        )
    }

    public var frame: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }

    public func clamped(minSize: CGSize) -> WindowState {
        let clampedWidth = max(width, Double(minSize.width))
        let clampedHeight = max(height, Double(minSize.height))
        return WindowState(x: x, y: y, width: clampedWidth, height: clampedHeight)
    }
}
