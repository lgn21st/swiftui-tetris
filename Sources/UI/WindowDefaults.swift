import AppKit

public enum WindowDefaults {
    public static func apply(to window: NSWindow) {
        window.isRestorable = false
        window.setFrameAutosaveName("")
        window.contentMinSize = CGSize(width: WindowConfig.minWidth, height: WindowConfig.minHeight)
        window.setContentSize(
            CGSize(width: WindowConfig.defaultWidth, height: WindowConfig.defaultHeight)
        )
        center(window)
    }

    private static func center(_ window: NSWindow) {
        guard let screen = window.screen ?? NSScreen.main else {
            window.center()
            return
        }
        let visible = screen.visibleFrame
        let frame = window.frame
        let origin = CGPoint(
            x: visible.midX - frame.size.width / 2,
            y: visible.midY - frame.size.height / 2
        )
        window.setFrameOrigin(origin)
    }
}
