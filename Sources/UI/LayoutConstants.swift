import SwiftUI

public enum LayoutConstants {
    public static let baseSize = CGSize(width: 480, height: 720)
    public static let basePadding: CGFloat = 16
    public static let baseGap: CGFloat = 16
    public static let baseAlignment: Alignment = .center
    public static let windowAlignment: Alignment = .center
    public static let scaleAnchor: UnitPoint = .center
    public static let cell: CGFloat = 24
    public static let boardWidth: CGFloat = 10 * cell
    public static let boardHeight: CGFloat = 20 * cell
    public static let panelWidth: CGFloat = baseSize.width - boardWidth - (basePadding * 2) - baseGap
    public static let contentWidth: CGFloat = boardWidth + panelWidth + baseGap
    public static let contentHeight: CGFloat = boardHeight
    public static let panelPadding: CGFloat = 12
    public static let previewCell: CGFloat = 12
    public static let panelSectionSpacing: CGFloat = 9.6
    public static let panelItemSpacing: CGFloat = 3.2
    public static let overlaySpacing: CGFloat = 8
    public static let hudSpacing: CGFloat = 6
    public static let panelCornerRadius: CGFloat = 8
    public static let panelShadowRadius: CGFloat = 10
    public static let panelBorderWidth: CGFloat = 1
    public static let boardBorderWidth: CGFloat = 1
    public static let overlayAnimationDuration: Double = 0.12
    public static let hudPadding: CGFloat = 8
    public static let hudCornerRadius: CGFloat = 6

    public static func overlayAnimation(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .easeOut(duration: overlayAnimationDuration)
    }
}
