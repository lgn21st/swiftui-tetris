import SwiftUI
import SpriteKit
import Renderer
import AppKit

public struct TetrisContainerView: View {
    @StateObject private var driver = SceneDriver()
    @StateObject private var windowCoordinator = WindowStateCoordinator()

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let scale = LayoutScale.scale(for: proxy.size)
            ZStack {
                HStack(spacing: 0) {
                    SpriteView(scene: driver.scene)
                        .frame(width: LayoutConstants.boardWidth, height: LayoutConstants.boardHeight)
                        .background(Color.black)
                    SidePanelView(state: driver.hudState)
                }
                .background(Color.black.opacity(ThemeConstants.backgroundOpacity))
                OverlayView(state: driver.overlayState)
                if driver.overlayState.isSettings {
                    SettingsView(settings: Binding(
                        get: { driver.settings },
                        set: { driver.settings = $0 }
                    ))
                    .transition(
                        .scale(scale: LayoutConstants.settingsEnterScale).combined(with: .opacity)
                    )
                }
                if driver.diagnosticsVisible {
                    DiagnosticsView(state: driver.diagnosticsState)
                }
                WindowStateView { window in
                    windowCoordinator.attach(to: window)
                }
                .frame(width: 0, height: 0)
                KeyCaptureView(
                    onKeyDown: { driver.handleKeyDown($0) },
                    onKeyUp: { driver.handleKeyUp($0) },
                    onToggleFullScreen: { windowCoordinator.toggleFullScreen() }
                )
                .frame(width: 0, height: 0)
            }
            .frame(width: LayoutConstants.baseSize.width, height: LayoutConstants.baseSize.height)
            .scaleEffect(scale)
            .animation(
                .easeOut(duration: LayoutConstants.settingsAnimationDuration),
                value: driver.overlayState.isSettings
            )
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
