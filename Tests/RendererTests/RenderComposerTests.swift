import XCTest
@testable import Renderer
@testable import Core

final class RenderComposerTests: XCTestCase {
    @available(*, deprecated, message: "RenderComposer is deprecated; tests assert legacy behavior only.")
    func testActiveOverridesGhost() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [(1, 1)],
            ghostBlocks: [(1, 1)],
            activeKind: .t,
            ghostKind: .t,
            softDropTrailBlocks: [],
            softDropTrailKind: nil,
            flashBlocks: [],
            flashAlpha: 0,
            isPaused: false,
            isGameOver: false
        )
        let cells = RenderComposer.compose(from: state)
        let cell = cells.first { $0.x == 1 && $0.y == 1 }
        XCTAssertEqual(cell?.isActive, true)
        XCTAssertEqual(cell?.isGhost, false)
        XCTAssertEqual(cell?.kind, .t)
    }

    @available(*, deprecated, message: "RenderComposer is deprecated; tests assert legacy behavior only.")
    func testGhostFillsEmptyCell() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [(2, 2)],
            activeKind: nil,
            ghostKind: .i,
            softDropTrailBlocks: [],
            softDropTrailKind: nil,
            flashBlocks: [],
            flashAlpha: 0,
            isPaused: false,
            isGameOver: false
        )
        let cells = RenderComposer.compose(from: state)
        let cell = cells.first { $0.x == 2 && $0.y == 2 }
        XCTAssertEqual(cell?.isGhost, true)
        XCTAssertEqual(cell?.kind, .i)
    }

    @available(*, deprecated, message: "RenderComposer is deprecated; tests assert legacy behavior only.")
    func testFlashMarksCells() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
            softDropTrailBlocks: [],
            softDropTrailKind: nil,
            flashBlocks: [(0, 0)],
            flashAlpha: 1,
            isPaused: false,
            isGameOver: false
        )
        let cells = RenderComposer.compose(from: state)
        let cell = cells.first { $0.x == 0 && $0.y == 0 }
        XCTAssertEqual(cell?.isFlash, true)
        XCTAssertEqual(cell?.kind, nil)
    }

    @available(*, deprecated, message: "RenderComposer is deprecated; tests assert legacy behavior only.")
    func testTrailMarksCells() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
            softDropTrailBlocks: [(4, 5)],
            softDropTrailKind: .s,
            flashBlocks: [],
            flashAlpha: 0,
            isPaused: false,
            isGameOver: false
        )
        let cells = RenderComposer.compose(from: state)
        let cell = cells.first { $0.x == 4 && $0.y == 5 }
        XCTAssertEqual(cell?.isTrail, true)
        XCTAssertEqual(cell?.kind, .s)
    }
}
