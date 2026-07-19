import Testing
@testable import Renderer
@testable import Core

@Suite struct RenderBufferTests {
    @Test func testActiveOverridesGhost() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [(1, 1)],
            ghostBlocks: [(1, 1)],
            activeKind: .t,
            ghostKind: .t,
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
        #expect(cell?.isActive == true)
        #expect(cell?.isGhost == false)
        #expect(cell?.kind == nil)
        #expect(buffer.changedIndices == [1 * Board.width + 1])
    }

    @Test func testGhostFillsEmptyCell() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [(2, 2)],
            activeKind: nil,
            ghostKind: .i,
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
        #expect(cell?.isGhost == true)
        #expect(cell?.kind == .i)
        #expect(buffer.changedIndices == [2 * Board.width + 2])
    }

    @Test func testFlashMarksCells() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
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
        #expect(cell?.isFlash == true)
        #expect(cell?.kind == nil)
        #expect(buffer.changedIndices == [0])
    }

    @Test func testUpdateReportsNoChangesWhenStateUnchanged() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [(3, 4)],
            ghostBlocks: [],
            activeKind: .l,
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
        let buffer = RenderBuffer()
        buffer.update(from: state)
        buffer.update(from: state)
        #expect(buffer.changedIndices == [])
    }

    @Test func testLineClearMarksRows() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
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
        #expect(buffer.lineClearIndices.count == Board.width)
        for x in 0..<Board.width {
            let cell = buffer.cells.first { $0.x == x && $0.y == 5 }
            #expect(cell?.isLineClear == true)
        }
    }

    @Test func testUpdateTracksFlashIndices() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [],
            ghostBlocks: [],
            activeKind: nil,
            ghostKind: nil,
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
        #expect(buffer.flashIndices == [0, 2 * Board.width + 3])
        #expect(buffer.changedIndices == [0, 2 * Board.width + 3])
    }

    @Test func testTrailIsIgnoredEvenWhenProvided() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
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
            isPaused: false,
            isGameOver: false
        )
        let buffer = RenderBuffer()
        buffer.update(from: state)
        let cell = buffer.cells.first { $0.x == 1 && $0.y == 2 }
        #expect(cell?.kind == nil)
    }

    @Test func testUpdateReusesInternalBuffers() {
        let board = Array(repeating: Array(repeating: TetrominoType?.none, count: 10), count: 20)
        let state = RenderState(
            board: board,
            activeBlocks: [(1, 1)],
            ghostBlocks: [(2, 2)],
            activeKind: .t,
            ghostKind: .i,
            flashBlocks: [(0, 0)],
            flashAlpha: 1,
            lineClearRows: [3],
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
        let touchedCapacity = buffer.debugTouchedCapacity()
        let dynamicCapacity = buffer.debugDynamicCapacity()
        buffer.update(from: state)
        #expect(buffer.debugTouchedCapacity() == touchedCapacity)
        #expect(buffer.debugDynamicCapacity() == dynamicCapacity)
    }
}
