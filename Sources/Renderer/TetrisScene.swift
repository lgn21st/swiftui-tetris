import SpriteKit
import Core

public final class TetrisScene: SKScene {
    public static let defaultSize = CGSize(width: 480, height: 720)
    public static let fixedStepMs: Double = 16
    public static let maxDeltaMs: Double = 250
    private let cellSize: CGFloat = 24
    private var cellNodes: [[SKShapeNode]] = []
    private var renderBuffer: RenderBuffer
    private var lastFlashAlpha: Double?
    private var clock: FixedStepClock
    private var frameClock: FrameClock
    public var onFixedStep: ((Int) -> Void)?
    public var onFrame: ((Int) -> Void)?
    public var onRender: (() -> RenderState?)?

    public override init(size: CGSize) {
        self.clock = FixedStepClock(stepMs: Self.fixedStepMs, maxDeltaMs: Self.maxDeltaMs)
        self.frameClock = FrameClock(maxDeltaMs: Self.maxDeltaMs)
        self.renderBuffer = RenderBuffer()
        super.init(size: size)
        commonInit()
    }

    public init(size: CGSize, stepMs: Double, maxDeltaMs: Double) {
        self.clock = FixedStepClock(stepMs: stepMs, maxDeltaMs: maxDeltaMs)
        self.frameClock = FrameClock(maxDeltaMs: maxDeltaMs)
        self.renderBuffer = RenderBuffer()
        super.init(size: size)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        self.clock = FixedStepClock(stepMs: Self.fixedStepMs, maxDeltaMs: Self.maxDeltaMs)
        self.frameClock = FrameClock(maxDeltaMs: Self.maxDeltaMs)
        self.renderBuffer = RenderBuffer()
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
        let changedIndices = renderBuffer.update(from: state)
        let shouldUpdateAll = lastFlashAlpha != state.flashAlpha
        lastFlashAlpha = state.flashAlpha
        if shouldUpdateAll {
            for cell in renderBuffer.cells {
                guard cell.y < cellNodes.count, cell.x < cellNodes[cell.y].count else { continue }
                let node = cellNodes[cell.y][cell.x]
                applyRender(cell: cell, state: state, node: node)
            }
            return
        }
        for index in changedIndices {
            guard index >= 0, index < renderBuffer.cells.count else { continue }
            let cell = renderBuffer.cells[index]
            guard cell.y < cellNodes.count, cell.x < cellNodes[cell.y].count else { continue }
            let node = cellNodes[cell.y][cell.x]
            applyRender(cell: cell, state: state, node: node)
        }
    }

    private func applyRender(cell: CellRender, state: RenderState, node: SKShapeNode) {
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

    private func commonInit() {
        scaleMode = .resizeFill
        backgroundColor = RenderTheme.boardBackgroundColor
        buildGrid()
    }

    private func shouldRender(state: RenderState) -> Bool {
        if state.isGameOver { return true }
        return !state.isPaused
    }
}
