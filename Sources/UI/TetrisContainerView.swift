import SwiftUI
import SpriteKit
import Renderer
import AppKit

public struct TetrisContainerView: View {
    @StateObject private var driver = SceneDriver()

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let scale = LayoutScale.scale(for: proxy.size)
            ZStack {
                SpriteView(scene: driver.scene)
                HUDView(state: driver.hudState)
                OverlayView(state: driver.overlayState)
                if driver.overlayState.isSettings {
                    SettingsView(settings: Binding(
                        get: { driver.settings },
                        set: { driver.settings = $0 }
                    ))
                }
                if driver.diagnosticsVisible {
                    DiagnosticsView(state: driver.diagnosticsState)
                }
                KeyCaptureView(
                    onKeyDown: { driver.handleKeyDown($0) },
                    onKeyUp: { driver.handleKeyUp($0) }
                )
                .frame(width: 0, height: 0)
            }
            .frame(width: WindowConfig.defaultWidth, height: WindowConfig.defaultHeight)
            .scaleEffect(scale)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .frame(minWidth: WindowConfig.minWidth, minHeight: WindowConfig.minHeight)
            .ignoresSafeArea()
            .onAppear { driver.start() }
            .onDisappear { driver.stop() }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
                driver.handleAppActiveChanged(isActive: false)
            }
        }
    }
}
