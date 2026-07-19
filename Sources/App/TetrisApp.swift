import SwiftUI
import UI
import Adapter

@main
struct TetrisApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let adapter = AdapterBootstrap.fromEnvironment()

    var body: some Scene {
        WindowGroup("SwiftUITetris") {
            TetrisContainerView(port: adapter)
        }
        .defaultSize(width: WindowConfig.defaultWidth, height: WindowConfig.defaultHeight)
        .windowResizability(WindowConfig.allowsResize ? .automatic : .contentSize)
        .commands {
            TetrisCommands()
        }
    }
}

private enum AdapterBootstrap {
    static func fromEnvironment() -> SocketAdapter? {
        guard let configuration = AdapterEnvironment.configuration() else { return nil }
        return SocketAdapter(configuration: configuration, startsImmediately: false)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppActivation.configure()
    }
}
