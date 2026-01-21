import SwiftUI
import UI

@main
struct TetrisApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("SwiftUITeris") {
            TetrisContainerView()
        }
        .defaultSize(width: WindowConfig.defaultWidth, height: WindowConfig.defaultHeight)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppActivation.configure()
    }
}
