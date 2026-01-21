import AppKit

public final class WindowStateCoordinator: ObservableObject {
    private let store: WindowStateStoring
    private weak var window: NSWindow?
    private var observers: [NSObjectProtocol] = []

    public init(store: WindowStateStoring = UserDefaultsWindowStateStore()) {
        self.store = store
    }

    public func attach(to window: NSWindow) {
        guard self.window !== window else { return }
        detachObservers()
        self.window = window
        applySavedState(to: window)
        observe(window)
    }

    public func toggleFullScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.window?.toggleFullScreen(nil)
        }
    }

    private func applySavedState(to window: NSWindow) {
        guard var state = store.load() else { return }
        state = state.clamped(minSize: CGSize(width: WindowConfig.minWidth, height: WindowConfig.minHeight))
        window.setFrame(state.frame, display: true)
    }

    private func observe(_ window: NSWindow) {
        let center = NotificationCenter.default
        observers = [
            center.addObserver(
                forName: NSWindow.didMoveNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                self?.saveWindowFrame()
            },
            center.addObserver(
                forName: NSWindow.didEndLiveResizeNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                self?.saveWindowFrame()
            }
        ]
    }

    private func saveWindowFrame() {
        guard let window, !window.styleMask.contains(.fullScreen) else { return }
        let state = WindowState(frame: window.frame)
            .clamped(minSize: CGSize(width: WindowConfig.minWidth, height: WindowConfig.minHeight))
        store.save(state)
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
