import Foundation
import Renderer
import Core

public final class SceneDriver: ObservableObject {
    public let scene: TetrisScene
    private let loop: GameLoop
    private var timer: Timer?
    private var lastTick: Date?

    public init(loop: GameLoop = GameLoop()) {
        self.scene = TetrisScene(size: TetrisScene.defaultSize)
        self.loop = loop
    }

    public func start() {
        guard timer == nil else { return }
        lastTick = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let now = Date()
            let elapsed = Int(now.timeIntervalSince(self.lastTick ?? now) * 1000)
            self.lastTick = now
            let renderState = self.loop.step(elapsedMs: max(elapsed, 0))
            self.scene.render(state: renderState)
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        lastTick = nil
    }
}
