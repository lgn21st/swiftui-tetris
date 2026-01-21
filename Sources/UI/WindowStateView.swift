import AppKit
import SwiftUI

public struct WindowStateView: NSViewRepresentable {
    public var onWindowAvailable: (NSWindow) -> Void

    public init(onWindowAvailable: @escaping (NSWindow) -> Void) {
        self.onWindowAvailable = onWindowAvailable
    }

    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            guard let window = view?.window else { return }
            onWindowAvailable(window)
        }
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { [weak nsView] in
            guard let window = nsView?.window else { return }
            onWindowAvailable(window)
        }
    }
}
