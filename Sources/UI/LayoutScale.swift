import SwiftUI

public enum LayoutScale {
    public static func scale(for size: CGSize, base: CGSize = CGSize(width: WindowConfig.defaultWidth, height: WindowConfig.defaultHeight)) -> CGFloat {
        let widthScale = size.width / base.width
        let heightScale = size.height / base.height
        return min(widthScale, heightScale)
    }
}
