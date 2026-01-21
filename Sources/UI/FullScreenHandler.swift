import AppKit

public protocol FullScreenHandling {
    func toggleFullScreen()
}

public struct AppKitFullScreenHandler: FullScreenHandling {
    public init() {}

    public func toggleFullScreen() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.toggleFullScreen(nil)
        }
    }
}
