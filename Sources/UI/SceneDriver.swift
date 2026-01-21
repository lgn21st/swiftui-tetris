import Foundation
import AppKit
import Combine
import Renderer
import Core

public final class SceneDriver: ObservableObject {
    public let scene: TetrisScene
    private let loop: GameLoop
    private let input: InputEngine
    private let audio: AudioEngine?
    private var gamepad: GamepadManager?
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
    private let settingsStore: SettingsStoring
    private var settingsCancellable: AnyCancellable?
    private var lastInputAction: GameAction?

    public init(
        loop: GameLoop = GameLoop(),
        input: InputEngine = InputEngine(),
        audio: AudioEngine? = AudioEngine(baseURL: AssetLocator.sfxDirectory()),
        settingsStore: SettingsStoring = UserDefaultsSettingsStore()
    ) {
        self.scene = TetrisScene(size: TetrisScene.defaultSize)
        self.loop = loop
        self.input = input
        self.audio = audio
        let startedValue = false
        self.started = startedValue
        self.showSettings = false
        self.hudState = HUDState.from(state: loop.state, started: startedValue)
        self.overlayState = OverlayState(isPaused: false, isGameOver: false, isTitle: true, isSettings: false)
        self.settingsStore = settingsStore
        self.settings = settingsStore.load()
        self.diagnosticsState = DiagnosticsState.empty
        self.diagnosticsVisible = false
        self.diagnosticsTracker = DiagnosticsTracker()
        self.lastInputAction = nil
        self.settingsCancellable = $settings.dropFirst().sink { [weak self] updated in
            self?.settingsStore.save(updated)
        }
        self.gamepad = GamepadManager(
            onLeftHeld: { [weak self] held in
                self?.setGamepadLeftHeld(held)
            },
            onRightHeld: { [weak self] held in
                self?.setGamepadRightHeld(held)
            },
            onDownHeld: { [weak self] held in
                self?.setGamepadDownHeld(held)
            },
            onAction: { [weak self] action in
                self?.handleGamepadAction(action)
            }
        )
    }

    public func start() {
        guard timer == nil else { return }
        lastTick = Date()
        gamepad?.start()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            let now = Date()
            let elapsed = Int(now.timeIntervalSince(self.lastTick ?? now) * 1000)
            self.lastTick = now
            self.tick(elapsedMs: elapsed)
        }
    }

    func tick(elapsedMs: Int) {
        let elapsed = max(elapsedMs, 0)
        let canAccept = !loop.state.paused && !loop.state.gameOver
        input.tick(elapsedMs: elapsed, canAccept: canAccept, state: &loop.state)
        let renderState = loop.step(elapsedMs: elapsed)
        diagnosticsState = diagnosticsTracker.recordFrame(elapsedMs: elapsed)
        let events = loop.state.takeSoundEvents()
        if let audio = audio, !settings.muted {
            for event in events {
                audio.play(
                    event,
                    masterVolume: settings.volume,
                    gainOverride: settings.gainOverride(for: event)
                )
            }
        }
        hudState = HUDState.from(
            state: loop.state,
            started: started,
            settings: settings,
            lastInput: lastInputAction
        )
        overlayState = OverlayState(
            isPaused: loop.state.paused || showSettings,
            isGameOver: loop.state.gameOver,
            isTitle: !started,
            isSettings: showSettings
        )
        scene.render(state: renderState)
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        lastTick = nil
        gamepad?.stop()
    }

    func stateSnapshot() -> GameState {
        loop.state
    }

    public func handleAppActiveChanged(isActive: Bool) {
        guard !isActive else { return }
        loop.state.paused = true
        input.reset()
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
        if key == "escape" {
            if showSettings {
                closeSettings()
            } else {
                recordLastInput(.pause)
                input.releaseMovementHolds()
                input.apply(action: .pause, to: &loop.state)
            }
            return
        }
        if key == "s" {
            setSettingsVisible(!showSettings)
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
        if showSettings {
            return
        }
        guard let action = KeyMapper.action(for: key) else { return }
        recordLastInput(action)
        switch action {
        case .moveLeft:
            input.setLeftHeld(true, state: &loop.state)
        case .moveRight:
            input.setRightHeld(true, state: &loop.state)
        case .softDrop:
            input.setDownHeld(true, state: &loop.state)
        case .pause:
            input.releaseMovementHolds()
            input.apply(action: action, to: &loop.state)
        default:
            input.apply(action: action, to: &loop.state)
        }
    }

    public func handleKeyUp(_ key: String) {
        if showSettings {
            return
        }
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

    public func toggleFullScreen() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.toggleFullScreen(nil)
        }
    }

    public func closeSettings() {
        setSettingsVisible(false)
    }

    private func handleGamepadAction(_ action: GameAction) {
        if showSettings {
            return
        }
        if !started, action == .pause || action == .restart {
            started = true
            loop.state.restart(seed: UInt64(loop.state.rng.peekUInt32()))
            return
        }
        recordLastInput(action)
        input.apply(action: action, to: &loop.state)
    }

    private func setGamepadLeftHeld(_ held: Bool) {
        if showSettings {
            return
        }
        if held { recordLastInput(.moveLeft) }
        input.setLeftHeld(held, state: &loop.state)
    }

    private func setGamepadRightHeld(_ held: Bool) {
        if showSettings {
            return
        }
        if held { recordLastInput(.moveRight) }
        input.setRightHeld(held, state: &loop.state)
    }

    private func setGamepadDownHeld(_ held: Bool) {
        if showSettings {
            return
        }
        if held { recordLastInput(.softDrop) }
        input.setDownHeld(held, state: &loop.state)
    }

    private func recordLastInput(_ action: GameAction) {
        lastInputAction = action
    }

    private func setSettingsVisible(_ visible: Bool) {
        showSettings = visible
        loop.state.paused = visible
        input.releaseMovementHolds()
        overlayState = OverlayState(
            isPaused: loop.state.paused || showSettings,
            isGameOver: loop.state.gameOver,
            isTitle: !started,
            isSettings: showSettings
        )
    }
}
