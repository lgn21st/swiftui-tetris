import SwiftUI
import AppKit

public struct KeyCaptureView: NSViewRepresentable {
    public var onKeyDown: (String) -> Void
    public var onKeyUp: (String) -> Void
    public var onToggleFullScreen: () -> Void

    public init(
        onKeyDown: @escaping (String) -> Void,
        onKeyUp: @escaping (String) -> Void,
        onToggleFullScreen: @escaping () -> Void = {}
    ) {
        self.onKeyDown = onKeyDown
        self.onKeyUp = onKeyUp
        self.onToggleFullScreen = onToggleFullScreen
    }

    public func makeNSView(context: Context) -> KeyCaptureNSView {
        let view = KeyCaptureNSView()
        view.onKeyDown = onKeyDown
        view.onKeyUp = onKeyUp
        view.onToggleFullScreen = onToggleFullScreen
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    public func updateNSView(_ nsView: KeyCaptureNSView, context: Context) {
        nsView.onKeyDown = onKeyDown
        nsView.onKeyUp = onKeyUp
        nsView.onToggleFullScreen = onToggleFullScreen
    }
}

public final class KeyCaptureNSView: NSView {
    var onKeyDown: ((String) -> Void)?
    var onKeyUp: ((String) -> Void)?
    var onToggleFullScreen: (() -> Void)?
    private var observers: [NSObjectProtocol] = []

    public override var acceptsFirstResponder: Bool {
        true
    }

    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        registerForWindowNotifications()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.window?.makeFirstResponder(self)
        }
    }

    public override func keyDown(with event: NSEvent) {
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
                window.makeFirstResponder(self)
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
