import SwiftUI
import Core

public enum TetrominoPalette {
    public static func color(for kind: TetrominoType?) -> Color {
        guard let kind else { return Color.clear }
        switch kind {
        case .i: return Color(red: 0.31, green: 0.82, blue: 0.77)
        case .o: return Color(red: 0.96, green: 0.88, blue: 0.37)
        case .t: return Color(red: 0.62, green: 0.48, blue: 0.92)
        case .s: return Color(red: 0.41, green: 0.83, blue: 0.57)
        case .z: return Color(red: 0.99, green: 0.51, blue: 0.51)
        case .j: return Color(red: 0.39, green: 0.70, blue: 0.93)
        case .l: return Color(red: 0.96, green: 0.68, blue: 0.33)
        }
    }
}
