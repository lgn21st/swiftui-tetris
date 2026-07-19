import Foundation
import Renderer
import Core
import Runtime
import Adapter

@MainActor public final class SceneDriver: ObservableObject {
    public let scene: TetrisScene
    private let runtime: GameRuntime
    private let input: InputEngine
    private let audio: AudioPlaying?
    private var gamepad: GamepadManager?
    private let fullScreenHandler: FullScreenHandling
    private let adapter: AdapterHandling?
    @Published public private(set) var hudState: HUDState
    @Published public private(set) var hudDiagnosticsState: HUDDiagnosticsState
    @Published public private(set) var overlayState: OverlayState
    @Published public private(set) var diagnosticsState: DiagnosticsState
    @Published public private(set) var diagnosticsVisible: Bool
    private var started: Bool
    private var diagnosticsTracker: DiagnosticsTracker
    private var lastInputAction: GameAction?
    private var latestRenderState: RenderState
    private let focusHandler: FocusPauseHandler
    private let masterVolume: Double
    private var ambientDucked: Bool
    private var diagnosticsAccumMs: Int
    @Published public private(set) var isMuted: Bool
    private var audioActive: Bool
    internal private(set) var debugRenderStateVersion: Int

    public init(
        state: GameState = GameState(config: GameConfig(), seed: 1),
        input: InputEngine = InputEngine(),
        audio: AudioPlaying? = AudioEngine(baseURL: AssetLocator.sfxDirectory()),
        fullScreenHandler: FullScreenHandling = AppKitFullScreenHandler(),
        scene: TetrisScene? = nil,
        adapter: AdapterHandling? = nil
    ) {
        self.scene = scene ?? TetrisScene(size: TetrisScene.defaultSize)
        self.input = input
        self.runtime = GameRuntime(state: state, input: input, port: adapter)
        self.audio = audio
        self.fullScreenHandler = fullScreenHandler
        self.adapter = adapter
        let startedValue = false
        self.started = startedValue
        let initialSnapshot = state.snapshot()
        self.hudState = HUDState.from(state: initialSnapshot, started: startedValue)
        self.hudDiagnosticsState = HUDDiagnosticsState.from(state: initialSnapshot)
        self.overlayState = OverlayState(
            isPaused: false,
            isGameOver: false,
            isTitle: true,
            onboardingHints: OverlayState.defaultOnboardingHints
        )
        self.diagnosticsState = DiagnosticsState.empty
        self.diagnosticsVisible = false
        self.diagnosticsTracker = DiagnosticsTracker()
        self.lastInputAction = nil
        self.latestRenderState = RenderMapper.map(snapshot: state.snapshot())
        self.debugRenderStateVersion = 0
        self.focusHandler = FocusPauseHandler()
        self.masterVolume = 0.7
        self.ambientDucked = false
        self.diagnosticsAccumMs = 0
        self.isMuted = false
        self.audioActive = false
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
        self.scene.onFrame = { [weak self] frameMs in
            guard let self else { return }
            self.diagnosticsAccumMs += frameMs
            if self.diagnosticsAccumMs >= 200 {
                self.diagnosticsAccumMs = 0
                self.diagnosticsState = self.diagnosticsTracker.recordFrame(elapsedMs: frameMs)
            }
            self.tick(elapsedMs: frameMs)
        }
        self.scene.onRender = { [weak self] in
            self?.latestRenderState
        }
    }

    public func start() {
        audioActive = true
        if !isMuted {
            audio?.setAmbientLoop(enabled: true, masterVolume: masterVolume)
        }
        gamepad?.start()
        (adapter as? AdapterLifecycle)?.start()
    }

    func tick(elapsedMs: Int) {
        runtime.advance(frameMs: elapsedMs)
        let snapshot = runtime.snapshot

        let shouldUpdateRenderState = !snapshot.paused || snapshot.gameOver
        if shouldUpdateRenderState {
            latestRenderState = RenderMapper.map(snapshot: snapshot)
            debugRenderStateVersion += 1
        }
        let events = runtime.takeSoundEvents()
        if !isMuted {
            if let audio = audio {
                for event in events {
                    audio.play(
                        event,
                        masterVolume: masterVolume,
                        gainOverride: nil
                    )
                }
            }
            let shouldDuck = snapshot.lineClearTimerMs > 0
            if shouldDuck != ambientDucked {
                audio?.setAmbientDucking(enabled: shouldDuck)
                ambientDucked = shouldDuck
            }
        }
        refreshDerivedState()
    }

    public func stop() {
        gamepad?.stop()
        audio?.setAmbientLoop(enabled: false, masterVolume: masterVolume)
        audioActive = false
        (adapter as? AdapterLifecycle)?.stop()
    }

    func stateSnapshot() -> GameStateSnapshot {
        runtime.snapshot
    }

    public func handleAppActiveChanged(isActive: Bool) {
        let snapshot = runtime.snapshot
        overlayState = focusHandler.handleAppActiveChanged(
            isActive: isActive,
            snapshot: snapshot,
            input: input,
            started: started
        )
        hudState = HUDState.from(
            state: snapshot,
            started: started,
            lastInput: lastInputAction
        )
        hudDiagnosticsState = HUDDiagnosticsState.from(
            state: snapshot,
            lastInput: lastInputAction
        )
    }

    public func handleKeyDown(_ key: String) {
        let normalized = key.lowercased()
        if normalized == "d" {
            diagnosticsVisible.toggle()
            return
        }
        if normalized == "m" {
            toggleMute()
            return
        }

        // Title screen: explicit start keys only start (no immediate action).
        if !started && (normalized == "\n" || normalized == "\r" || normalized == " " || normalized == "space") {
            startIfNeeded()
            refreshDerivedState()
            return
        }

        guard let action = InputRouter.action(forKey: normalized) else { return }

        if ensureStartedForInput(action: action) {
            return
        }

        recordLastInput(action)
        switch action {
        case .moveLeft:
            if let action = input.setLeftHeld(true) { runtime.enqueue(action) }
        case .moveRight:
            if let action = input.setRightHeld(true) { runtime.enqueue(action) }
        case .softDrop:
            if let action = input.setDownHeld(true) { runtime.enqueue(action) }
        case .pause:
            input.releaseMovementHolds()
            runtime.enqueue(action)
        default:
            runtime.enqueue(action)
        }

        refreshDerivedState()
    }

    public func handleKeyUp(_ key: String) {
        guard let action = InputRouter.action(forKey: key) else { return }
        switch action {
        case .moveLeft:
            _ = input.setLeftHeld(false)
        case .moveRight:
            _ = input.setRightHeld(false)
        case .softDrop:
            _ = input.setDownHeld(false)
        default:
            break
        }
    }

    public func toggleFullScreen() {
        fullScreenHandler.toggleFullScreen()
    }

    public func commandStartGame() {
        startIfNeeded()
        refreshDerivedState()
    }

    public func commandRestartGame() {
        started = true
        runtime.enqueue(.restart)
        input.reset()
        refreshDerivedState()
    }

    public func commandTogglePause() {
        recordLastInput(.pause)
        input.releaseMovementHolds()
        runtime.enqueue(.pause)
        refreshDerivedState()
    }

    public func commandToggleMute() {
        toggleMute()
    }

    private func handleGamepadAction(_ action: GameAction) {
        if ensureStartedForInput(action: action) {
            return
        }
        recordLastInput(action)
        runtime.enqueue(action)
        refreshDerivedState()
    }

    /// Ensures the title overlay is cleared before applying inputs.
    /// Returns true when the input should be consumed (e.g. `.restart` on title should just start).
    private func ensureStartedForInput(action: GameAction) -> Bool {
        guard !started else { return false }
        startIfNeeded()
        refreshDerivedState()

        // Avoid double-restart and avoid starting into a paused state.
        if action == .restart || action == .pause {
            return true
        }
        return false
    }

    private func setGamepadLeftHeld(_ held: Bool) {
        if held { recordLastInput(.moveLeft) }
        if let action = input.setLeftHeld(held) { runtime.enqueue(action) }
    }

    private func setGamepadRightHeld(_ held: Bool) {
        if held { recordLastInput(.moveRight) }
        if let action = input.setRightHeld(held) { runtime.enqueue(action) }
    }

    private func setGamepadDownHeld(_ held: Bool) {
        if held { recordLastInput(.softDrop) }
        if let action = input.setDownHeld(held) { runtime.enqueue(action) }
    }

    private func recordLastInput(_ action: GameAction) {
        lastInputAction = action
    }

    private func refreshDerivedState() {
        let snapshot = runtime.snapshot
        hudState = HUDState.from(
            state: snapshot,
            started: started,
            lastInput: lastInputAction
        )
        hudDiagnosticsState = HUDDiagnosticsState.from(
            state: snapshot,
            lastInput: lastInputAction
        )
        overlayState = OverlayState(
            isPaused: snapshot.paused,
            isGameOver: snapshot.gameOver,
            isTitle: !started,
            onboardingHints: !started ? OverlayState.defaultOnboardingHints : []
        )
    }

    private func startIfNeeded() {
        if !started {
            started = true
            runtime.enqueue(.restart)
        }
    }

    private func toggleMute() {
        setMuted(!isMuted)
    }

    private func setMuted(_ muted: Bool) {
        guard isMuted != muted else { return }
        isMuted = muted
        if muted {
            audio?.setAmbientLoop(enabled: false, masterVolume: masterVolume)
            audio?.setAmbientDucking(enabled: false)
            ambientDucked = false
            return
        }
        guard audioActive else { return }
        audio?.setAmbientLoop(enabled: true, masterVolume: masterVolume)
        let shouldDuck = runtime.snapshot.lineClearTimerMs > 0
        audio?.setAmbientDucking(enabled: shouldDuck)
        ambientDucked = shouldDuck
    }
}
