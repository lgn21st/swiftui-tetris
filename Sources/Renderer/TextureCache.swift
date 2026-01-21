import SpriteKit
import AppKit
import Core

public final class TextureCache {
    public enum PieceStyle: Hashable {
        case normal
        case highlight
        case trail
    }

    public enum Key: Hashable {
        case piece(kind: TetrominoType, ghost: Bool, style: PieceStyle)
        case flash
    }

    private let cellSize: CGFloat
    private var textures: [Key: SKTexture]

    public init(cellSize: CGFloat) {
        self.cellSize = cellSize
        self.textures = [:]
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
            style = .normal
        }
        let texture = makeTexture(color: color, style: style)
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
        case .trail:
            baseColor = color.withAlphaComponent(0.35)
        case .highlight, .normal:
            baseColor = color
        }
        baseColor.setFill()
        NSBezierPath(rect: rect).fill()

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
        case .trail:
            let outline = rect.insetBy(dx: 0.75, dy: 0.75)
            let strokeColor = color.blended(withFraction: 0.55, of: .white) ?? color
            strokeColor.withAlphaComponent(0.6).setStroke()
            let path = NSBezierPath(rect: outline)
            path.lineWidth = 1
            path.stroke()
        case .normal:
            break
        }
        image.unlockFocus()
        return SKTexture(image: image)
    }
}
