import SwiftUI
import AppKit

public struct KeyCaptureView: NSViewRepresentable {
    public var onKeyDown: (String) -> Void
    public var onKeyUp: (String) -> Void

    public init(onKeyDown: @escaping (String) -> Void, onKeyUp: @escaping (String) -> Void) {
        self.onKeyDown = onKeyDown
        self.onKeyUp = onKeyUp
    }

    public func makeNSView(context: Context) -> KeyCaptureNSView {
        let view = KeyCaptureNSView()
        view.onKeyDown = onKeyDown
        view.onKeyUp = onKeyUp
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    public func updateNSView(_ nsView: KeyCaptureNSView, context: Context) {
        nsView.onKeyDown = onKeyDown
        nsView.onKeyUp = onKeyUp
    }
}

public final class KeyCaptureNSView: NSView {
    var onKeyDown: ((String) -> Void)?
    var onKeyUp: ((String) -> Void)?

    public override var acceptsFirstResponder: Bool {
        true
    }

    public override func keyDown(with event: NSEvent) {
        onKeyDown?(event.charactersIgnoringModifiers ?? "")
    }

    public override func keyUp(with event: NSEvent) {
        onKeyUp?(event.charactersIgnoringModifiers ?? "")
    }
}
