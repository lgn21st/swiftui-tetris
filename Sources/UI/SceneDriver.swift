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
    @Published public private(set) var hudState: HUDState
    @Published public private(set) var overlayState: OverlayState
    @Published public var settings: SettingsState
    @Published public private(set) var diagnosticsState: DiagnosticsState
    @Published public private(set) var diagnosticsVisible: Bool
    private var started: Bool
    private var showSettings: Bool
    private var diagnosticsTracker: DiagnosticsTracker

    public init(
        loop: GameLoop = GameLoop(),
        input: InputEngine = InputEngine(),
        audio: AudioEngine? = AudioEngine(baseURL: AssetLocator.sfxDirectory())
    ) {
        self.scene = TetrisScene(size: TetrisScene.defaultSize)
        self.loop = loop
        self.input = input
        self.audio = audio
        self.hudState = HUDState.from(state: loop.state)
        self.overlayState = OverlayState(isPaused: false, isGameOver: false, isTitle: true, isSettings: false)
        self.settings = SettingsState()
        self.diagnosticsState = DiagnosticsState.empty
        self.diagnosticsVisible = false
        self.started = false
        self.showSettings = false
        self.diagnosticsTracker = DiagnosticsTracker()
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
            self.diagnosticsState = self.diagnosticsTracker.recordFrame(elapsedMs: elapsed)
            let events = self.loop.state.takeSoundEvents()
            if let audio = self.audio, !self.settings.muted {
                for event in events {
                    audio.play(event)
                }
            }
            self.hudState = HUDState.from(state: self.loop.state)
            self.overlayState = OverlayState(
                isPaused: self.loop.state.paused || self.showSettings,
                isGameOver: self.loop.state.gameOver,
                isTitle: !self.started,
                isSettings: self.showSettings
            )
            self.scene.render(state: renderState)
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        lastTick = nil
    }

    func stateSnapshot() -> GameState {
        loop.state
    }

    public func handleAppActiveChanged(isActive: Bool) {
        guard !isActive else { return }
        loop.state.paused = true
        overlayState = OverlayState(
            isPaused: true,
            isGameOver: loop.state.gameOver,
            isTitle: !started,
            isSettings: showSettings
        )
    }

    public func handleKeyDown(_ key: String) {
        if !started && (key == "\n" || key == "\r" || key == " " || key == "space") {
            if !started {
                started = true
                loop.state.restart(seed: UInt64(loop.state.rng.peekUInt32()))
            }
            return
        }
        if key == "s" {
            showSettings.toggle()
            loop.state.paused = showSettings
            return
        }
        if key == "m" {
            settings.toggleMute()
            return
        }
        if key == "+" || key == "=" {
            settings.adjustVolume(by: 0.1)
            return
        }
        if key == "-" {
            settings.adjustVolume(by: -0.1)
            return
        }
        if key == "0" {
            settings.reset()
            return
        }
        if key == "d" {
            diagnosticsVisible.toggle()
            return
        }
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
