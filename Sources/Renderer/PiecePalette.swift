import Core
import SpriteKit

public enum PiecePalette {
    public static func color(for kind: TetrominoType?, ghost: Bool) -> SKColor {
        guard let kind else {
            return SKColor.clear
        }
        let base: SKColor
        switch kind {
        case .i: base = SKColor(red: 0.31, green: 0.82, blue: 0.77, alpha: 1)
        case .o: base = SKColor(red: 0.96, green: 0.88, blue: 0.37, alpha: 1)
        case .t: base = SKColor(red: 0.62, green: 0.48, blue: 0.92, alpha: 1)
        case .s: base = SKColor(red: 0.41, green: 0.83, blue: 0.57, alpha: 1)
        case .z: base = SKColor(red: 0.99, green: 0.51, blue: 0.51, alpha: 1)
        case .j: base = SKColor(red: 0.39, green: 0.70, blue: 0.93, alpha: 1)
        case .l: base = SKColor(red: 0.96, green: 0.68, blue: 0.33, alpha: 1)
        }
        if ghost {
            return base.withAlphaComponent(0.25)
        }
        return base
    }
}
