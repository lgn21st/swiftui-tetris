import AppKit

public protocol ApplicationActivating {
    func setActivationPolicy(_ policy: NSApplication.ActivationPolicy) -> Bool
    func activate(ignoringOtherApps flag: Bool)
}

extension NSApplication: ApplicationActivating {}

public enum AppActivation {
    public static func configure(app: ApplicationActivating = NSApplication.shared) {
        _ = app.setActivationPolicy(.regular)
        app.activate(ignoringOtherApps: true)
    }
}
