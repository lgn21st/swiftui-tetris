import SpriteKit
import Core

public final class TetrisScene: SKScene {
    public static let defaultSize = CGSize(width: 480, height: 720)
    public static let fixedStepMs: Double = 16
    public static let maxDeltaMs: Double = 250
    private let cellSize: CGFloat = 24
    private var cellNodes: [[SKSpriteNode]] = []
    private var renderBuffer: RenderBuffer
    private var lastFlashAlpha: Double?
    private var clock: FixedStepClock
    private var frameClock: FrameClock
    private var textureCache: TextureCache
    public var onFixedStep: ((Int) -> Void)?
    public var onFrame: ((Int) -> Void)?
    public var onRender: (() -> RenderState?)?

    public override init(size: CGSize) {
        self.clock = FixedStepClock(stepMs: Self.fixedStepMs, maxDeltaMs: Self.maxDeltaMs)
        self.frameClock = FrameClock(maxDeltaMs: Self.maxDeltaMs)
        self.renderBuffer = RenderBuffer()
        self.textureCache = TextureCache(cellSize: cellSize)
        super.init(size: size)
        commonInit()
    }

    public init(size: CGSize, stepMs: Double, maxDeltaMs: Double) {
        self.clock = FixedStepClock(stepMs: stepMs, maxDeltaMs: maxDeltaMs)
        self.frameClock = FrameClock(maxDeltaMs: maxDeltaMs)
        self.renderBuffer = RenderBuffer()
        self.textureCache = TextureCache(cellSize: cellSize)
        super.init(size: size)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        self.clock = FixedStepClock(stepMs: Self.fixedStepMs, maxDeltaMs: Self.maxDeltaMs)
        self.frameClock = FrameClock(maxDeltaMs: Self.maxDeltaMs)
        self.renderBuffer = RenderBuffer()
        self.textureCache = TextureCache(cellSize: cellSize)
        super.init(coder: coder)
        commonInit()
    }

    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let frameMs = frameClock.advance(currentTime: currentTime)
        if frameMs > 0 {
            onFrame?(frameMs)
        }
        let steps = clock.advance(currentTime: currentTime)
        if steps > 0 {
            onFixedStep?(steps)
        }
        if let renderState = onRender?(), shouldRender(state: renderState) {
            render(state: renderState)
        }
    }

    public func render(state: RenderState) {
        renderBuffer.update(from: state)
        let flashAlphaChanged = lastFlashAlpha != state.flashAlpha
        lastFlashAlpha = state.flashAlpha
        if flashAlphaChanged {
            for index in renderBuffer.changedIndices {
                guard index >= 0, index < renderBuffer.cells.count else { continue }
                let cell = renderBuffer.cells[index]
                guard cell.y < cellNodes.count, cell.x < cellNodes[cell.y].count else { continue }
                let node = cellNodes[cell.y][cell.x]
                applyRender(cell: cell, state: state, node: node)
            }
            for index in renderBuffer.flashIndices {
                guard index >= 0, index < renderBuffer.cells.count else { continue }
                let cell = renderBuffer.cells[index]
                guard cell.y < cellNodes.count, cell.x < cellNodes[cell.y].count else { continue }
                let node = cellNodes[cell.y][cell.x]
                applyRender(cell: cell, state: state, node: node)
            }
            return
        }
        for index in renderBuffer.changedIndices {
            guard index >= 0, index < renderBuffer.cells.count else { continue }
            let cell = renderBuffer.cells[index]
            guard cell.y < cellNodes.count, cell.x < cellNodes[cell.y].count else { continue }
            let node = cellNodes[cell.y][cell.x]
            applyRender(cell: cell, state: state, node: node)
        }
    }

    private func applyRender(cell: CellRender, state: RenderState, node: SKSpriteNode) {
        if cell.isFlash {
            if state.flashAlpha <= 0 {
                clear(node: node)
            } else {
                node.isHidden = false
                node.texture = textureCache.texture(for: .flash)
                node.alpha = CGFloat(state.flashAlpha)
            }
            return
        }
        guard let kind = cell.kind else {
            clear(node: node)
            return
        }
        if cell.isTrail {
            node.isHidden = false
            node.alpha = 1
            node.texture = textureCache.texture(for: .piece(kind: kind, ghost: false, style: .trail))
            return
        }
        node.isHidden = false
        let isGhost = cell.isGhost && !cell.isActive
        let style: TextureCache.PieceStyle = cell.isActive ? .highlight : .normal
        node.texture = textureCache.texture(for: .piece(kind: kind, ghost: isGhost, style: style))
        if cell.isActive {
            let pulse = max(0, min(state.activePulse, 1))
            node.alpha = CGFloat(0.85 + 0.15 * pulse)
        } else {
            node.alpha = 1
        }
    }

    private func buildGrid() {
        cellNodes = Array(repeating: Array(repeating: SKSpriteNode(), count: Board.width), count: Board.height)
        for y in 0..<Board.height {
            for x in 0..<Board.width {
                let node = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: cellSize, height: cellSize))
                node.isHidden = true
                let originX = CGFloat(x) * cellSize + cellSize / 2
                let originY = CGFloat(Board.height - 1 - y) * cellSize + cellSize / 2
                node.position = CGPoint(x: originX, y: originY)
                addChild(node)
                cellNodes[y][x] = node
            }
        }
    }

    private func commonInit() {
        scaleMode = .resizeFill
        backgroundColor = RenderTheme.boardBackgroundColor
        buildGrid()
        addGridlines()
    }

    private func addGridlines() {
        let gridPath = BoardGrid.path(cellSize: cellSize)
        let gridNode = SKShapeNode(path: gridPath)
        gridNode.strokeColor = RenderTheme.gridlineColor
        gridNode.lineWidth = RenderTheme.gridlineWidth
        gridNode.zPosition = RenderTheme.gridlineZ
        gridNode.isAntialiased = false
        addChild(gridNode)
    }

    private func clear(node: SKSpriteNode) {
        node.texture = nil
        node.alpha = 1
        node.isHidden = true
    }

    private func shouldRender(state: RenderState) -> Bool {
        if state.isGameOver { return true }
        return !state.isPaused
    }
}
