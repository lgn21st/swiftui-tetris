import Foundation
import Renderer
import Core
import Adapter

public final class SceneDriver: ObservableObject {
    public let scene: TetrisScene
    private let loop: GameLoop
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
        loop: GameLoop = GameLoop(),
        input: InputEngine = InputEngine(),
        audio: AudioPlaying? = AudioEngine(baseURL: AssetLocator.sfxDirectory()),
        fullScreenHandler: FullScreenHandling = AppKitFullScreenHandler(),
        scene: TetrisScene? = nil,
        adapter: AdapterHandling? = nil
    ) {
        self.scene = scene ?? TetrisScene(size: TetrisScene.defaultSize)
        self.loop = loop
        self.input = input
        self.audio = audio
        self.fullScreenHandler = fullScreenHandler
        self.adapter = adapter
        let startedValue = false
        self.started = startedValue
        self.hudState = HUDState.from(state: loop.state, started: startedValue)
        self.hudDiagnosticsState = HUDDiagnosticsState.from(state: loop.state)
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
        self.latestRenderState = RenderMapper.map(snapshot: loop.state.snapshot())
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
        self.scene.onFixedStep = { [weak self] steps in
            let elapsed = Int(Double(steps) * TetrisScene.fixedStepMs)
            self?.tick(elapsedMs: elapsed, fixedSteps: steps)
        }
        self.scene.onFrame = { [weak self] frameMs in
            guard let self else { return }
            self.diagnosticsAccumMs += frameMs
            if self.diagnosticsAccumMs < 200 { return }
            self.diagnosticsAccumMs = 0
            self.diagnosticsState = self.diagnosticsTracker.recordFrame(elapsedMs: frameMs)
        }
        self.scene.onRender = { [weak self] in
            self?.latestRenderState
        }
        adapter?.emit(snapshot: loop.state.snapshot())
    }

    public func start() {
        audioActive = true
        if !isMuted {
            audio?.setAmbientLoop(enabled: true, masterVolume: masterVolume)
        }
        gamepad?.start()
        (adapter as? AdapterLifecycle)?.start()
    }

    func tick(elapsedMs: Int, fixedSteps: Int = 1) {
        let elapsed = max(elapsedMs, 0)
        let stepCount = max(fixedSteps, 1)
        let baseStepMs = elapsed / stepCount
        let remainderMs = elapsed % stepCount

        for stepIndex in 0..<stepCount {
            let stepElapsed = baseStepMs + (stepIndex < remainderMs ? 1 : 0)
            loop.state.beginFixedStep()
            adapter?.poll(elapsedMs: stepElapsed, state: &loop.state)
            let canAccept = !loop.state.paused && !loop.state.gameOver
            input.tick(elapsedMs: stepElapsed, canAccept: canAccept, state: &loop.state)
            loop.state.advanceFixedStep()
            loop.state.tick(elapsedMs: stepElapsed, softDrop: false)
            adapter?.emit(snapshot: loop.state.snapshot())
        }

        let shouldUpdateRenderState = !loop.state.paused || loop.state.gameOver
        if shouldUpdateRenderState {
            latestRenderState = RenderMapper.map(snapshot: loop.state.snapshot())
            debugRenderStateVersion += 1
        }
        let events = loop.state.takeSoundEvents()
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
            let shouldDuck = loop.state.lineClearTimerMs > 0
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

    func stateSnapshot() -> GameState {
        loop.state
    }

    public func handleAppActiveChanged(isActive: Bool) {
        overlayState = focusHandler.handleAppActiveChanged(
            isActive: isActive,
            state: &loop.state,
            input: input,
            started: started
        )
        hudState = HUDState.from(
            state: loop.state,
            started: started,
            lastInput: lastInputAction
        )
        hudDiagnosticsState = HUDDiagnosticsState.from(
            state: loop.state,
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

        refreshDerivedState()
    }

    public func handleKeyUp(_ key: String) {
        guard let action = InputRouter.action(forKey: key) else { return }
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
        fullScreenHandler.toggleFullScreen()
    }

    public func commandStartGame() {
        startIfNeeded()
        refreshDerivedState()
    }

    public func commandRestartGame() {
        started = true
        loop.state.restart(seed: UInt64(loop.state.rng.peekUInt32()))
        input.reset()
        refreshDerivedState()
    }

    public func commandTogglePause() {
        recordLastInput(.pause)
        input.releaseMovementHolds()
        input.apply(action: .pause, to: &loop.state)
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
        input.apply(action: action, to: &loop.state)
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
        input.setLeftHeld(held, state: &loop.state)
    }

    private func setGamepadRightHeld(_ held: Bool) {
        if held { recordLastInput(.moveRight) }
        input.setRightHeld(held, state: &loop.state)
    }

    private func setGamepadDownHeld(_ held: Bool) {
        if held { recordLastInput(.softDrop) }
        input.setDownHeld(held, state: &loop.state)
    }

    private func recordLastInput(_ action: GameAction) {
        lastInputAction = action
    }

    private func refreshDerivedState() {
        hudState = HUDState.from(
            state: loop.state,
            started: started,
            lastInput: lastInputAction
        )
        hudDiagnosticsState = HUDDiagnosticsState.from(
            state: loop.state,
            lastInput: lastInputAction
        )
        overlayState = OverlayState(
            isPaused: loop.state.paused,
            isGameOver: loop.state.gameOver,
            isTitle: !started,
            onboardingHints: !started ? OverlayState.defaultOnboardingHints : []
        )
    }

    private func startIfNeeded() {
        if !started {
            started = true
            loop.state.restart(seed: UInt64(loop.state.rng.peekUInt32()))
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
        let shouldDuck = loop.state.lineClearTimerMs > 0
        audio?.setAmbientDucking(enabled: shouldDuck)
        ambientDucked = shouldDuck
    }
}
