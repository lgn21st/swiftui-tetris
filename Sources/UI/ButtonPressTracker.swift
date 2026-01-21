public struct ButtonPressTracker {
    private var wasPressed: Bool
    private let threshold: Float

    public init(threshold: Float = 0.5) {
        self.wasPressed = false
        self.threshold = threshold
    }

    public mutating func update(value: Float, pressed: Bool) -> Bool {
        let isPressed = pressed || value >= threshold
        defer { wasPressed = isPressed }
        return isPressed && !wasPressed
    }
}
