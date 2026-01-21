import SpriteKit
import AppKit
import Core

public final class TextureCache {
    public enum PieceStyle: Hashable {
        case normal
        case highlight
        case ghost
        case flashOutline
        case flashBorder
    }

    public enum Key: Hashable {
        case piece(kind: TetrominoType, ghost: Bool, style: PieceStyle)
        case flash
        case lineClear
    }

    private let cellSize: CGFloat
    private var textures: [Key: SKTexture]

    public init(cellSize: CGFloat) {
        self.cellSize = cellSize
        self.textures = [:]
    }

    public func prewarm() {
        let styles: [PieceStyle] = [.normal, .highlight, .ghost, .flashBorder]
        for kind in TetrominoType.allCases {
            for style in styles {
                _ = texture(for: .piece(kind: kind, ghost: style == .ghost, style: style))
            }
        }
        _ = texture(for: .lineClear)
        _ = texture(for: .flash)
    }

    public func texture(for key: Key) -> SKTexture {
        if let cached = textures[key] {
            return cached
        }
        let color: SKColor
        let style: PieceStyle
        switch key {
        case .piece(let kind, let ghost, let pieceStyle):
            color = PiecePalette.color(for: kind, ghost: ghost)
            style = pieceStyle
        case .flash:
            color = SKColor(white: 1.0, alpha: 1.0)
            style = .flashOutline
        case .lineClear:
            color = SKColor(white: 0.95, alpha: 1.0)
            style = .normal
        }
        let texture = key == .lineClear
            ? makeLineClearTexture(color: color)
            : makeTexture(color: color, style: style)
        textures[key] = texture
        return texture
    }

    private func makeTexture(color: SKColor, style: PieceStyle) -> SKTexture {
        let size = NSSize(width: cellSize, height: cellSize)
        let image = NSImage(size: size)
        image.lockFocus()
        let rect = NSRect(origin: .zero, size: size)
        let baseColor: SKColor
        switch style {
        case .highlight, .normal, .ghost, .flashBorder:
            baseColor = color
        case .flashOutline:
            baseColor = color.withAlphaComponent(0)
        }
        if style != .flashOutline {
            baseColor.setFill()
            NSBezierPath(rect: rect).fill()
        }

        switch style {
        case .highlight:
            let border = rect.insetBy(dx: 0.5, dy: 0.5)
            let strokeColor = color.blended(withFraction: 0.35, of: .white) ?? color
            strokeColor.setStroke()
            let path = NSBezierPath(rect: border)
            path.lineWidth = 1
            path.stroke()
            let glossHeight = max(rect.height * 0.28, 2)
            let glossRect = NSRect(
                x: rect.minX + 1,
                y: rect.maxY - glossHeight - 1,
                width: rect.width - 2,
                height: glossHeight
            )
            let glossColor = strokeColor.withAlphaComponent(0.5)
            glossColor.setFill()
            NSBezierPath(rect: glossRect).fill()
        case .ghost:
            let outline = rect.insetBy(dx: 0.5, dy: 0.5)
            let strokeColor = color
            strokeColor.setStroke()
            let path = NSBezierPath(rect: outline)
            path.lineWidth = 1
            path.stroke()
        case .normal:
            break
        case .flashOutline:
            let outline = rect.insetBy(dx: 0.7, dy: 0.7)
            let strokeColor = RenderTheme.flashBorderColor
            strokeColor.setStroke()
            let path = NSBezierPath(rect: outline)
            path.lineWidth = 1.4
            path.stroke()
        case .flashBorder:
            let outline = rect.insetBy(dx: 0.7, dy: 0.7)
            let strokeColor = RenderTheme.flashBorderColor
            strokeColor.setStroke()
            let path = NSBezierPath(rect: outline)
            path.lineWidth = 1.4
            path.stroke()
        }
        image.unlockFocus()
        return SKTexture(image: image)
    }

    private func makeLineClearTexture(color: SKColor) -> SKTexture {
        let size = NSSize(width: cellSize, height: cellSize)
        let image = NSImage(size: size)
        image.lockFocus()
        let rect = NSRect(origin: .zero, size: size)
        color.setFill()
        NSBezierPath(rect: rect).fill()

        let stripeColor = color.blended(withFraction: 0.6, of: .white) ?? color
        stripeColor.withAlphaComponent(0.7).setStroke()
        let path = NSBezierPath()
        let inset: CGFloat = 2
        path.move(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset))
        path.line(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
        path.lineWidth = max(1, cellSize * 0.08)
        path.stroke()

        image.unlockFocus()
        return SKTexture(image: image)
    }
}
