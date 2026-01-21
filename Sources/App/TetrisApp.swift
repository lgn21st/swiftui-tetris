import SwiftUI
import UI

@main
struct TetrisApp: App {
    var body: some Scene {
        WindowGroup("SwiftUITeris") {
            TetrisContainerView()
        }
        .defaultSize(width: WindowConfig.defaultWidth, height: WindowConfig.defaultHeight)
    }
}
