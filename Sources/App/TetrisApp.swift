import SwiftUI
import UI

@main
struct TetrisApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("SwiftUITetris") {
            TetrisContainerView()
        }
        .defaultSize(width: WindowConfig.defaultWidth, height: WindowConfig.defaultHeight)
        .windowResizability(WindowConfig.allowsResize ? .automatic : .contentSize)
        .commands {
            TetrisCommands()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppActivation.configure()
    }
}
