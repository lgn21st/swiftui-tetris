@preconcurrency import GameController
import Core

@MainActor public final class GamepadManager {
    private let onLeftHeld: (Bool) -> Void
    private let onRightHeld: (Bool) -> Void
    private let onDownHeld: (Bool) -> Void
    private let onAction: (GameAction) -> Void
    private let observerBag = NotificationObserverBag()
    private var started = false

    public init(
        onLeftHeld: @escaping (Bool) -> Void,
        onRightHeld: @escaping (Bool) -> Void,
        onDownHeld: @escaping (Bool) -> Void,
        onAction: @escaping (GameAction) -> Void
    ) {
        self.onLeftHeld = onLeftHeld
        self.onRightHeld = onRightHeld
        self.onDownHeld = onDownHeld
        self.onAction = onAction
    }

    public func start() {
        guard !started else { return }
        started = true
        observeControllers()
        GCController.startWirelessControllerDiscovery {}
        for controller in GCController.controllers() {
            configure(controller)
        }
    }

    public func stop() {
        guard started else { return }
        started = false
        GCController.stopWirelessControllerDiscovery()
        detachObservers()
    }

    private func observeControllers() {
        let center = NotificationCenter.default
        observerBag.values = [
            center.addObserver(
                forName: .GCControllerDidConnect,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let controller = notification.object as? GCController else { return }
                let reference = ControllerReference(controller)
                MainActor.assumeIsolated {
                    self?.configure(reference.value)
                }
            },
            center.addObserver(
                forName: .GCControllerDidDisconnect,
                object: nil,
                queue: .main
            ) { _ in }
        ]
    }

    private func configure(_ controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }
        bindDpad(gamepad.dpad)
        bindButton(gamepad.buttonA, as: .buttonA)
        bindButton(gamepad.buttonB, as: .buttonB)
        bindButton(gamepad.buttonX, as: .buttonX)
        bindButton(gamepad.buttonY, as: .buttonY)
        bindButton(gamepad.leftShoulder, as: .leftShoulder)
        bindButton(gamepad.rightShoulder, as: .rightShoulder)
        if let options = gamepad.buttonOptions {
            bindButton(options, as: .options)
        }
        bindButton(gamepad.buttonMenu, as: .menu)
    }

    private func bindDpad(_ dpad: GCControllerDirectionPad) {
        dpad.left.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.onLeftHeld(pressed)
        }
        dpad.right.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.onRightHeld(pressed)
        }
        dpad.down.pressedChangedHandler = { [weak self] _, _, pressed in
            self?.onDownHeld(pressed)
        }
        dpad.up.pressedChangedHandler = { [weak self] _, _, pressed in
            guard pressed else { return }
            self?.handleButton(.dpadUp)
        }
    }

    private func bindButton(_ button: GCControllerButtonInput, as mapped: GamepadButton) {
        var tracker = ButtonPressTracker()
        let handle: (Float, Bool) -> Void = { [weak self] value, pressed in
            if tracker.update(value: value, pressed: pressed) {
                self?.handleButton(mapped)
            }
        }
        button.pressedChangedHandler = { _, value, pressed in
            handle(value, pressed)
        }
        button.valueChangedHandler = { _, value, pressed in
            handle(value, pressed)
        }
    }

    private func handleButton(_ button: GamepadButton) {
        guard let action = InputRouter.action(forButton: button) else { return }
        onAction(action)
    }

    private func detachObservers() {
        let center = NotificationCenter.default
        for observer in observerBag.values {
            center.removeObserver(observer)
        }
        observerBag.values = []
    }
}

private final class NotificationObserverBag: @unchecked Sendable {
    var values: [NSObjectProtocol] = []

    deinit {
        for observer in values {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

private final class ControllerReference: @unchecked Sendable {
    let value: GCController

    init(_ value: GCController) {
        self.value = value
    }
}
