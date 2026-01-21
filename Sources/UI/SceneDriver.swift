import Foundation
import Renderer
import Core

public final class SceneDriver: ObservableObject {
    public let scene: TetrisScene
    private let loop: GameLoop
    private let input: InputEngine
    private let audio: AudioEngine?
    private var timer: Timer?
    private var lastTick: Date?

    public init(loop: GameLoop = GameLoop(), input: InputEngine = InputEngine(), audio: AudioEngine? = nil) {
        self.scene = TetrisScene(size: TetrisScene.defaultSize)
        self.loop = loop
        self.input = input
        self.audio = audio
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
            let events = self.loop.state.takeSoundEvents()
            if let audio = self.audio {
                for event in events {
                    audio.play(event)
                }
            }
            self.scene.render(state: renderState)
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        lastTick = nil
    }

    public func handleKeyDown(_ key: String) {
        guard let action = KeyMapper.action(for: key) else { return }
        switch action {
        case .moveLeft:
            input.setLeftHeld(true, state: &loop.state)
        case .moveRight:
            input.setRightHeld(true, state: &loop.state)
        case .softDrop:
            input.setDownHeld(true, state: &loop.state)
        default:
            input.apply(action: action, to: &loop.state)
        }
    }

    public func handleKeyUp(_ key: String) {
        guard let action = KeyMapper.action(for: key) else { return }
        switch action {
        case .moveLeft:
            input.setLeftHeld(false, state: &loop.state)
        case .moveRight:
            input.setRightHeld(false, state: &loop.state)
        case .softDrop:
            input.setDownHeld(false, state: &loop.state)
        default:
            break
        }
    }
}
