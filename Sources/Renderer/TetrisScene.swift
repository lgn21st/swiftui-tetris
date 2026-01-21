import SpriteKit
import Core

public final class TetrisScene: SKScene {
    public static let defaultSize = CGSize(width: 480, height: 720)
    public static let fixedStepMs: Double = 16
    public static let maxDeltaMs: Double = 250
    private let cellSize: CGFloat = 24
    private var cellNodes: [[SKSpriteNode]] = []
    private var activeNodes: [SKSpriteNode] = []
    private var renderBuffer: RenderBuffer
    private var lastFlashAlpha: Double?
    private var lastLineClearAlpha: Double?
    private var clock: FixedStepClock
    private var frameClock: FrameClock
    private var textureCache: TextureCache
    private var scorePopupNodes: [SKLabelNode] = []
    private var tSpinBadge: SKLabelNode?
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
        if let renderState = onRender?(), shouldRender(state: renderState), Self.canRender(view: view) {
            render(state: renderState)
        }
    }

    public func render(state: RenderState) {
        renderBuffer.update(from: state)
        let flashAlphaChanged = lastFlashAlpha != state.flashAlpha
        lastFlashAlpha = state.flashAlpha
        let lineClearAlphaChanged = lastLineClearAlpha != state.lineClearAlpha
        lastLineClearAlpha = state.lineClearAlpha
        if flashAlphaChanged || lineClearAlphaChanged {
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
            for index in renderBuffer.lineClearIndices {
                guard index >= 0, index < renderBuffer.cells.count else { continue }
                let cell = renderBuffer.cells[index]
                guard cell.y < cellNodes.count, cell.x < cellNodes[cell.y].count else { continue }
                let node = cellNodes[cell.y][cell.x]
                applyRender(cell: cell, state: state, node: node)
            }
            renderActiveOverlay(state)
            renderScorePopups(state.scorePopups)
            renderTSpinBadge(state)
            return
        }
        for index in renderBuffer.changedIndices {
            guard index >= 0, index < renderBuffer.cells.count else { continue }
            let cell = renderBuffer.cells[index]
            guard cell.y < cellNodes.count, cell.x < cellNodes[cell.y].count else { continue }
            let node = cellNodes[cell.y][cell.x]
            applyRender(cell: cell, state: state, node: node)
        }
        renderActiveOverlay(state)
        renderScorePopups(state.scorePopups)
        renderTSpinBadge(state)
    }

    private func applyRender(cell: CellRender, state: RenderState, node: SKSpriteNode) {
        if cell.isLineClear {
            if state.lineClearAlpha <= 0 {
                clear(node: node)
            } else {
                node.isHidden = false
                node.texture = textureCache.texture(for: .lineClear)
                node.alpha = CGFloat(state.lineClearAlpha)
            }
            return
        }
        guard let kind = cell.kind else {
            clear(node: node)
            return
        }
        node.isHidden = false
        let isGhost = cell.isGhost && !cell.isActive
        let style: TextureCache.PieceStyle
        if cell.isFlash {
            style = .flashBorder
        } else if isGhost {
            style = .ghost
        } else {
            style = .normal
        }
        node.texture = textureCache.texture(for: .piece(kind: kind, ghost: isGhost, style: style))
        node.alpha = 1
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

    private func renderActiveOverlay(_ state: RenderState) {
        guard !state.activeBlocks.isEmpty, state.activeKind != nil else {
            for node in activeNodes {
                node.isHidden = true
            }
            return
        }

        if activeNodes.count != state.activeBlocks.count {
            for node in activeNodes {
                node.removeFromParent()
            }
            activeNodes = state.activeBlocks.map { _ in
                let node = SKSpriteNode(texture: nil, color: .clear, size: CGSize(width: cellSize, height: cellSize))
                node.zPosition = 5
                node.isHidden = true
                addChild(node)
                return node
            }
        }

        for (index, node) in activeNodes.enumerated() {
            guard index < state.activeBlocks.count, let kind = state.activeKind else {
                node.isHidden = true
                continue
            }
            let (x, y) = state.activeBlocks[index]
            let originX = CGFloat(x) * cellSize + cellSize / 2
            let originY = CGFloat(Board.height - 1 - y) * cellSize + cellSize / 2
            node.position = CGPoint(x: originX, y: originY)
            if state.isGrounded {
                node.texture = textureCache.texture(for: .piece(kind: kind, ghost: false, style: .normal))
                node.alpha = 1
            } else {
                node.texture = textureCache.texture(for: .piece(kind: kind, ghost: false, style: .highlight))
                let pulse = max(0, min(state.activePulse, 1))
                node.alpha = CGFloat(0.85 + 0.15 * pulse)
            }
            node.isHidden = false
        }
    }
    internal func debugCellNode(atX x: Int, y: Int) -> SKSpriteNode {
        cellNodes[y][x]
    }

    internal func debugActiveNodes() -> [SKSpriteNode] {
        activeNodes
    }

    private func commonInit() {
        scaleMode = .resizeFill
        backgroundColor = RenderTheme.boardBackgroundColor
        buildGrid()
        addGridlines()
        addTSpinBadge()
    }

    private func renderScorePopups(_ popups: [ScorePopup]) {
        if popups.count > scorePopupNodes.count {
            for _ in scorePopupNodes.count..<popups.count {
                let node = SKLabelNode(fontNamed: "Menlo-Bold")
                node.fontSize = 16
                node.fontColor = .white
                node.zPosition = 10
                node.isHidden = true
                addChild(node)
                scorePopupNodes.append(node)
            }
        }
        for (index, node) in scorePopupNodes.enumerated() {
            guard index < popups.count else {
                node.isHidden = true
                continue
            }
            let popup = popups[index]
            node.text = popup.text
            node.alpha = CGFloat(popup.alpha)
            node.isHidden = false
            let position = CGPoint(
                x: CGFloat(popup.x) * cellSize + cellSize / 2,
                y: CGFloat(Board.height - 1) * cellSize
                    - CGFloat(popup.y) * cellSize
                    + cellSize / 2
            )
            node.position = position
        }
    }

    private func addTSpinBadge() {
        let badge = SKLabelNode(fontNamed: "Menlo-Bold")
        badge.fontSize = 18
        badge.fontColor = .white
        badge.zPosition = 12
        badge.isHidden = true
        addChild(badge)
        tSpinBadge = badge
    }

    private func renderTSpinBadge(_ state: RenderState) {
        guard let badge = tSpinBadge else { return }
        guard state.tSpinKind != .none, state.tSpinAlpha > 0 else {
            badge.isHidden = true
            return
        }
        badge.text = state.tSpinKind == .mini ? "Mini T-Spin" : "T-Spin"
        badge.alpha = CGFloat(state.tSpinAlpha)
        badge.isHidden = false
        let boardWidth = CGFloat(Board.width) * cellSize
        let boardHeight = CGFloat(Board.height) * cellSize
        badge.position = CGPoint(x: boardWidth / 2, y: boardHeight + cellSize * 0.6)
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

    static func canRender(view: SKView?) -> Bool {
        guard let view else { return false }
        if view.isHidden { return false }
        if view.window == nil { return false }
        let boundsSize = view.bounds.size
        if boundsSize.width <= 0 || boundsSize.height <= 0 { return false }
        return true
    }
}
