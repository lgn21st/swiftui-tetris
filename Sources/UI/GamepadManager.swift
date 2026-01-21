import GameController
import Core

public final class GamepadManager {
    private let onLeftHeld: (Bool) -> Void
    private let onRightHeld: (Bool) -> Void
    private let onDownHeld: (Bool) -> Void
    private let onAction: (GameAction) -> Void
    private var observers: [NSObjectProtocol] = []
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
        observers = [
            center.addObserver(
                forName: .GCControllerDidConnect,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let controller = notification.object as? GCController else { return }
                self?.configure(controller)
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
        button.pressedChangedHandler = { [weak self] _, _, pressed in
            guard pressed else { return }
            self?.handleButton(mapped)
        }
    }

    private func handleButton(_ button: GamepadButton) {
        guard let action = GamepadMapping.action(for: button) else { return }
        onAction(action)
    }

    private func detachObservers() {
        let center = NotificationCenter.default
        for observer in observers {
            center.removeObserver(observer)
        }
        observers = []
    }

    deinit {
        detachObservers()
    }
}
