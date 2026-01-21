import XCTest
@testable import Renderer
@testable import Core

final class TetrisSceneRenderTests: XCTestCase {
    func testSceneRendersEachUpdateWhenProviderAvailable() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var renderCalls = 0
        scene.onRender = {
            renderCalls += 1
            return Self.emptyRenderState()
        }

        scene.update(1.0)
        scene.update(1.1)

        XCTAssertEqual(renderCalls, 2)
    }

    func testSceneSkipsRenderWhenPaused() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var renderCalls = 0
        scene.onRender = {
            renderCalls += 1
            return Self.emptyRenderState(isPaused: true, isGameOver: false)
        }

        scene.update(1.0)
        scene.update(1.1)

        XCTAssertEqual(renderCalls, 2)
    }

    func testSceneRendersWhenGameOverEvenIfPaused() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var renderCalls = 0
        scene.onRender = {
            renderCalls += 1
            return Self.emptyRenderState(isPaused: true, isGameOver: true)
        }

        scene.update(1.0)
        scene.update(1.1)

        XCTAssertEqual(renderCalls, 2)
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
            isPaused: isPaused,
            isGameOver: isGameOver
        )
    }
}
