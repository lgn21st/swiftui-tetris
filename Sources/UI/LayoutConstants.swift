import SwiftUI

public enum LayoutConstants {
    public static let baseSize = CGSize(width: 480, height: 720)
    public static let cell: CGFloat = 24
    public static let boardWidth: CGFloat = 10 * cell
    public static let boardHeight: CGFloat = 20 * cell
    public static let panelWidth: CGFloat = baseSize.width - boardWidth
    public static let panelPadding: CGFloat = 12
    public static let previewCell: CGFloat = 12
    public static let panelSectionSpacing: CGFloat = 12
    public static let panelItemSpacing: CGFloat = 6
    public static let overlaySpacing: CGFloat = 8
    public static let settingsSpacing: CGFloat = 8
    public static let hudSpacing: CGFloat = 6
    public static let settingsMaxWidth: CGFloat = 260
    public static let panelCornerRadius: CGFloat = 8
}
