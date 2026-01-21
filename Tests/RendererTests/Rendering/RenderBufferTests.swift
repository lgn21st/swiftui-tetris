import XCTest
@testable import Renderer
@testable import Core

final class RenderBufferTests: XCTestCase {
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
        let buffer = RenderBuffer()
        buffer.update(from: state)
        let cell = buffer.cells.first { $0.x == 1 && $0.y == 1 }
        XCTAssertEqual(cell?.isActive, true)
        XCTAssertEqual(cell?.isGhost, false)
        XCTAssertNil(cell?.kind)
        XCTAssertEqual(buffer.changedIndices, [1 * Board.width + 1])
    }

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
        let buffer = RenderBuffer()
        buffer.update(from: state)
        let cell = buffer.cells.first { $0.x == 2 && $0.y == 2 }
        XCTAssertEqual(cell?.isGhost, true)
        XCTAssertEqual(cell?.kind, .i)
        XCTAssertEqual(buffer.changedIndices, [2 * Board.width + 2])
    }

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
        let buffer = RenderBuffer()
        buffer.update(from: state)
        let cell = buffer.cells.first { $0.x == 0 && $0.y == 0 }
        XCTAssertEqual(cell?.isFlash, true)
        XCTAssertEqual(cell?.kind, nil)
        XCTAssertEqual(buffer.changedIndices, [0])
    }

    func testUpdateReportsNoChangesWhenStateUnchanged() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [(3, 4)],
            ghostBlocks: [],
            activeKind: .l,
            ghostKind: nil,
            softDropTrailBlocks: [],
            softDropTrailKind: nil,
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
        let buffer = RenderBuffer()
        buffer.update(from: state)
        buffer.update(from: state)
        XCTAssertEqual(buffer.changedIndices, [])
    }

    func testLineClearMarksRows() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
            softDropTrailBlocks: [],
            softDropTrailKind: nil,
            flashBlocks: [],
            flashAlpha: 0,
            lineClearRows: [5],
            lineClearAlpha: 1,
            scorePopups: [],
            tSpinKind: .none,
            tSpinAlpha: 0,
            activePulse: 0,
            isGrounded: false,
            isPaused: false,
            isGameOver: false
        )
        let buffer = RenderBuffer()
        buffer.update(from: state)
        XCTAssertEqual(buffer.lineClearIndices.count, Board.width)
        for x in 0..<Board.width {
            let cell = buffer.cells.first { $0.x == x && $0.y == 5 }
            XCTAssertEqual(cell?.isLineClear, true)
        }
    }

    func testUpdateTracksFlashIndices() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
            softDropTrailBlocks: [],
            softDropTrailKind: nil,
            flashBlocks: [(0, 0), (3, 2)],
            flashAlpha: 1,
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
        let buffer = RenderBuffer()
        buffer.update(from: state)
        XCTAssertEqual(buffer.flashIndices, [0, 2 * Board.width + 3])
        XCTAssertEqual(buffer.changedIndices, [0, 2 * Board.width + 3])
    }

    func testTrailIsIgnoredEvenWhenProvided() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
            softDropTrailBlocks: [(1, 2)],
            softDropTrailKind: .t,
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
        let buffer = RenderBuffer()
        buffer.update(from: state)
        let cell = buffer.cells.first { $0.x == 1 && $0.y == 2 }
        XCTAssertEqual(cell?.isTrail, false)
        XCTAssertNil(cell?.kind)
    }
}
