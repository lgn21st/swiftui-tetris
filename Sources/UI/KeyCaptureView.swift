import SwiftUI
import AppKit

public struct KeyCaptureView: NSViewRepresentable {
    public var onKeyDown: (String) -> Void
    public var onKeyUp: (String) -> Void
    public var onToggleFullScreen: () -> Void
    public var isEnabled: Bool

    public init(
        onKeyDown: @escaping (String) -> Void,
        onKeyUp: @escaping (String) -> Void,
        onToggleFullScreen: @escaping () -> Void = {},
        isEnabled: Bool = true
    ) {
        self.onKeyDown = onKeyDown
        self.onKeyUp = onKeyUp
        self.onToggleFullScreen = onToggleFullScreen
        self.isEnabled = isEnabled
    }

    public func makeNSView(context: Context) -> KeyCaptureNSView {
        let view = KeyCaptureNSView()
        view.onKeyDown = onKeyDown
        view.onKeyUp = onKeyUp
        view.onToggleFullScreen = onToggleFullScreen
        view.isEnabled = isEnabled
        DispatchQueue.main.async {
            if view.isEnabled {
                view.window?.makeFirstResponder(view)
            }
        }
        return view
    }

    public func updateNSView(_ nsView: KeyCaptureNSView, context: Context) {
        nsView.onKeyDown = onKeyDown
        nsView.onKeyUp = onKeyUp
        nsView.onToggleFullScreen = onToggleFullScreen
        nsView.isEnabled = isEnabled
    }
}

public final class KeyCaptureNSView: NSView {
    var onKeyDown: ((String) -> Void)?
    var onKeyUp: ((String) -> Void)?
    var onToggleFullScreen: (() -> Void)?
    var isEnabled: Bool = true {
        didSet {
            if !isEnabled {
                window?.makeFirstResponder(nil)
            }
        }
    }
    private var observers: [NSObjectProtocol] = []

    public override var acceptsFirstResponder: Bool {
        isEnabled
    }

    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        registerForWindowNotifications()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.isEnabled {
                self.window?.makeFirstResponder(self)
            }
        }
    }

    public override func keyDown(with event: NSEvent) {
        guard isEnabled else { return }
        if let key = event.charactersIgnoringModifiers,
           KeyCommandMapper.isFullScreenToggle(key: key, modifiers: event.modifierFlags) {
            onToggleFullScreen?()
            return
        }
        if let mapped = KeyCodeMapper.keyString(for: event.keyCode) {
            onKeyDown?(mapped)
        } else if let chars = event.charactersIgnoringModifiers {
            onKeyDown?(chars)
        }
    }

    public override func keyUp(with event: NSEvent) {
        guard isEnabled else { return }
        if let mapped = KeyCodeMapper.keyString(for: event.keyCode) {
            onKeyUp?(mapped)
        } else if let chars = event.charactersIgnoringModifiers {
            onKeyUp?(chars)
        }
    }

    private func registerForWindowNotifications() {
        removeObservers()
        guard let window else { return }
        let center = NotificationCenter.default
        observers = [
            center.addObserver(
                forName: NSWindow.didBecomeKeyNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                if self.isEnabled {
                    window.makeFirstResponder(self)
                }
            }
        ]
    }

    private func removeObservers() {
        let center = NotificationCenter.default
        for observer in observers {
            center.removeObserver(observer)
        }
        observers = []
    }

    deinit {
        removeObservers()
    }
}
