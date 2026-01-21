import SwiftUI

public enum LayoutConstants {
    public static let baseSize = CGSize(width: 480, height: 720)
    public static let cell: CGFloat = 24
    public static let boardWidth: CGFloat = 10 * cell
    public static let boardHeight: CGFloat = 20 * cell
    public static let panelWidth: CGFloat = baseSize.width - boardWidth
    public static let panelPadding: CGFloat = 12
    public static let previewCell: CGFloat = 12
}
