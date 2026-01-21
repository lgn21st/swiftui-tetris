import SwiftUI
import SpriteKit
import Renderer

public struct TetrisContainerView: View {
    private let scene = TetrisScene(size: TetrisScene.defaultSize)

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: scene)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .ignoresSafeArea()
        }
    }
}
