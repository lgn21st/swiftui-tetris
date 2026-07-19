import Testing
import AppKit
import SpriteKit
@testable import Renderer
@testable import Core

@Suite @MainActor struct TetrisSceneRenderTests {
    @Test func testSceneRendersEachUpdateWhenProviderAvailable() {
        let scene = TetrisScene(size: TetrisScene.defaultSize)
        var renderCalls = 0
        scene.onRender = {
            renderCalls += 1
            return Self.emptyRenderState()
        }

        scene.update(1.0)
        scene.update(1.1)

        #expect(renderCalls == 2)
    }

    @Test func testSceneSkipsRenderWhenPaused() {
        let scene = TetrisScene(size: TetrisScene.defaultSize)
        var renderCalls = 0
        scene.onRender = {
            renderCalls += 1
            return Self.emptyRenderState(isPaused: true, isGameOver: false)
        }

        scene.update(1.0)
        scene.update(1.1)

        #expect(renderCalls == 2)
    }

    @Test func testSceneRendersWhenGameOverEvenIfPaused() {
        let scene = TetrisScene(size: TetrisScene.defaultSize)
        var renderCalls = 0
        scene.onRender = {
            renderCalls += 1
            return Self.emptyRenderState(isPaused: true, isGameOver: true)
        }

        scene.update(1.0)
        scene.update(1.1)

        #expect(renderCalls == 2)
    }

    @Test func testSceneRendersActiveOverlayWithoutBoardCells() {
        let scene = TetrisScene(size: TetrisScene.defaultSize)
        let activeBlocks = [(4, 0), (5, 0), (4, 1), (5, 1)]
        let renderState = Self.emptyRenderState(
            activeBlocks: activeBlocks,
            activeKind: .o
        )

        scene.render(state: renderState)

        let activeNodes = scene.debugActiveNodes()
        #expect(activeNodes.count == activeBlocks.count)
        for node in activeNodes {
            #expect(!node.isHidden)
            #expect(node.texture != nil)
        }
        for (x, y) in activeBlocks {
            #expect(scene.debugCellNode(atX: x, y: y).isHidden)
        }
    }

    @Test func testCanRenderReturnsFalseForNilView() {
        #expect(!TetrisScene.canRender(view: nil))
    }

    @Test func testCanRenderRequiresWindowAndSize() {
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        #expect(!TetrisScene.canRender(view: view))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.contentView = view
        #expect(TetrisScene.canRender(view: view))
        view.frame = .zero
        #expect(!TetrisScene.canRender(view: view))
    }

    private static func emptyRenderState(isPaused: Bool = false, isGameOver: Bool = false) -> RenderState {
        let row = Array<TetrominoType?>(repeating: nil, count: Board.width)
        let board = Array(repeating: row, count: Board.height)
        return RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
            flashBlocks: [],
            flashAlpha: 0,
            lineClearRows: [],
            lineClearAlpha: 0,
            scorePopups: [],
            tSpinKind: .none,
            tSpinAlpha: 0,
            activePulse: 0,
            isGrounded: false,
            isPaused: isPaused,
            isGameOver: isGameOver
        )
    }

    private static func emptyRenderState(
        activeBlocks: [(Int, Int)],
        activeKind: TetrominoType?
    ) -> RenderState {
        let row = Array<TetrominoType?>(repeating: nil, count: Board.width)
        let board = Array(repeating: row, count: Board.height)
        return RenderState(
            board: board,
            activeBlocks: activeBlocks,
            ghostBlocks: [],
            activeKind: activeKind,
            ghostKind: nil,
            flashBlocks: [],
            flashAlpha: 0,
            lineClearRows: [],
            lineClearAlpha: 0,
            scorePopups: [],
            tSpinKind: .none,
            tSpinAlpha: 0,
            activePulse: 0,
            isGrounded: false,
            isPaused: false,
            isGameOver: false
        )
    }
}
