import SwiftUI
import SpriteKit
import Renderer

public struct TetrisContainerView: View {
    @StateObject private var driver = SceneDriver()

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                SpriteView(scene: driver.scene)
                HUDView(state: driver.hudState)
                OverlayView(state: driver.overlayState)
                KeyCaptureView(
                    onKeyDown: { driver.handleKeyDown($0) },
                    onKeyUp: { driver.handleKeyUp($0) }
                )
                .frame(width: 0, height: 0)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .ignoresSafeArea()
            .onAppear { driver.start() }
            .onDisappear { driver.stop() }
        }
    }
}
