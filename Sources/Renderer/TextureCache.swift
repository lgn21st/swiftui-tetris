import SpriteKit
import AppKit
import Core

public final class TextureCache {
    public enum Key: Hashable {
        case piece(kind: TetrominoType, ghost: Bool)
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
        switch key {
        case .piece(let kind, let ghost):
            color = PiecePalette.color(for: kind, ghost: ghost)
        case .flash:
            color = SKColor(white: 1.0, alpha: 1.0)
        }
        let texture = makeTexture(color: color)
        textures[key] = texture
        return texture
    }

    private func makeTexture(color: SKColor) -> SKTexture {
        let size = NSSize(width: cellSize, height: cellSize)
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        image.unlockFocus()
        return SKTexture(image: image)
    }
}
