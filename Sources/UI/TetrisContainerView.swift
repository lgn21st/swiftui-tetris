import SwiftUI
import SpriteKit
import Renderer
import AppKit

public struct TetrisContainerView: View {
    @StateObject private var driver = SceneDriver()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let scale = LayoutScale.scale(for: proxy.size)
            ZStack(alignment: LayoutConstants.baseAlignment) {
                Color(
                    red: ThemeConstants.appBackgroundRed,
                    green: ThemeConstants.appBackgroundGreen,
                    blue: ThemeConstants.appBackgroundBlue
                )
                .frame(
                    width: LayoutConstants.baseSize.width,
                    height: LayoutConstants.baseSize.height
                )
                HStack(alignment: .top, spacing: LayoutConstants.baseGap) {
                    SpriteView(scene: driver.scene)
                        .frame(width: LayoutConstants.boardWidth, height: LayoutConstants.boardHeight)
                        .background(
                            Color(
                                red: ThemeConstants.boardBackgroundRed,
                                green: ThemeConstants.boardBackgroundGreen,
                                blue: ThemeConstants.boardBackgroundBlue
                            )
                        )
                        .overlay(
                            Rectangle().stroke(
                                Color(
                                    red: ThemeConstants.borderColorRed,
                                    green: ThemeConstants.borderColorGreen,
                                    blue: ThemeConstants.borderColorBlue,
                                    opacity: ThemeConstants.panelBorderOpacity
                                ),
                                lineWidth: LayoutConstants.boardBorderWidth
                            )
                        )
                    SidePanelView(state: driver.hudState)
                }
                .frame(
                    width: LayoutConstants.contentWidth,
                    height: LayoutConstants.contentHeight,
                    alignment: .topLeading
                )
                .padding(LayoutConstants.basePadding)
                OverlayView(state: driver.overlayState)
                    .frame(
                        width: LayoutConstants.baseSize.width,
                        height: LayoutConstants.baseSize.height,
                        alignment: .topLeading
                    )
                if driver.overlayState.isSettings {
                    SettingsView(settings: Binding(
                        get: { driver.settings },
                        set: { driver.settings = $0 }
                    ))
                    .transition(
                        .scale(scale: LayoutConstants.settingsEnterScale).combined(with: .opacity)
                    )
                    .frame(
                        width: LayoutConstants.baseSize.width,
                        height: LayoutConstants.baseSize.height,
                        alignment: .center
                    )
                }
                if driver.diagnosticsVisible {
                    DiagnosticsView(state: driver.diagnosticsState)
                        .frame(
                            width: LayoutConstants.baseSize.width,
                            height: LayoutConstants.baseSize.height,
                            alignment: .topLeading
                        )
                }
                KeyCaptureView(
                    onKeyDown: { driver.handleKeyDown($0) },
                    onKeyUp: { driver.handleKeyUp($0) },
                    onToggleFullScreen: { driver.toggleFullScreen() }
                )
                .frame(width: 0, height: 0)
                WindowStateView { window in
                    WindowDefaults.apply(to: window)
                }
            }
            .frame(
                width: LayoutConstants.baseSize.width,
                height: LayoutConstants.baseSize.height,
                alignment: LayoutConstants.baseAlignment
            )
            .scaleEffect(scale, anchor: LayoutConstants.scaleAnchor)
            .animation(
                LayoutConstants.settingsAnimation(reduceMotion: reduceMotion),
                value: driver.overlayState.isSettings
            )
            .frame(
                width: proxy.size.width,
                height: proxy.size.height,
                alignment: LayoutConstants.windowAlignment
            )
            .frame(minWidth: WindowConfig.minWidth, minHeight: WindowConfig.minHeight)
            .background(
                Color(
                    red: ThemeConstants.appBackgroundRed,
                    green: ThemeConstants.appBackgroundGreen,
                    blue: ThemeConstants.appBackgroundBlue
                )
            )
            .onAppear { driver.start() }
            .onDisappear { driver.stop() }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)) { _ in
                driver.handleAppActiveChanged(isActive: false)
            }
        }
    }
}
