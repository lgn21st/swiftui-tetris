import SwiftUI
import SpriteKit
import Renderer

public struct TetrisContainerView: View {
    @StateObject private var driver = SceneDriver()

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: driver.scene)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .ignoresSafeArea()
                .onAppear { driver.start() }
                .onDisappear { driver.stop() }
        }
    }
}
