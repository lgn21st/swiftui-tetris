import SpriteKit
import Core

public final class TetrisScene: SKScene {
    public static let defaultSize = CGSize(width: 480, height: 720)
    private let cellSize: CGFloat = 24
    private var cellNodes: [[SKShapeNode]] = []

    public override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .black
        buildGrid()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        scaleMode = .resizeFill
        backgroundColor = .black
        buildGrid()
    }

    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Placeholder for tick-driven updates.
    }

    public func render(state: RenderState) {
        let composed = RenderComposer.compose(from: state)
        for cell in composed {
            guard cell.y < cellNodes.count, cell.x < cellNodes[cell.y].count else { continue }
            let node = cellNodes[cell.y][cell.x]
            if cell.isFlash {
                if state.flashAlpha <= 0 {
                    node.fillColor = .clear
                    node.strokeColor = .clear
                } else {
                    let flash = PiecePalette.flashColor.withAlphaComponent(CGFloat(state.flashAlpha))
                    node.fillColor = flash
                    node.strokeColor = flash
                }
            } else if cell.kind == nil && !cell.isGhost && !cell.isActive {
                node.fillColor = .clear
                node.strokeColor = .clear
            } else {
                node.fillColor = PiecePalette.color(for: cell.kind, ghost: cell.isGhost && !cell.isActive)
                node.strokeColor = node.fillColor
            }
        }
    }

    private func buildGrid() {
        cellNodes = Array(repeating: Array(repeating: SKShapeNode(), count: Board.width), count: Board.height)
        for y in 0..<Board.height {
            for x in 0..<Board.width {
                let node = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
                node.strokeColor = .clear
                node.fillColor = .clear
                node.lineWidth = 1
                let originX = CGFloat(x) * cellSize + cellSize / 2
                let originY = CGFloat(Board.height - 1 - y) * cellSize + cellSize / 2
                node.position = CGPoint(x: originX, y: originY)
                addChild(node)
                cellNodes[y][x] = node
            }
        }
    }
}
