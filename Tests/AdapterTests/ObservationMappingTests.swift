import XCTest
import Core
@testable import Adapter

final class ObservationMappingTests: XCTestCase {
    func testMapsSnapshotToObservation() {
        var state = GameState(config: GameConfig(), seed: 7)
        state.score = 1200
        state.level = 2
        state.lines = 17
        state.paused = true
        state.gameOver = false
        state.hold = .z
        state.canHold = true
        state.nextQueue = [.i, .o, .t, .s, .z]
        state.active = Tetromino(kind: .t, x: 4, y: 0)
        state.active.rotation = .east
        state.board.cells[0][0] = Cell(filled: true, kind: .t)

        let snapshot = state.snapshot()
        let observation = ObservationMapper.map(snapshot: snapshot, seq: 42, tsMs: 1700000000000)

        XCTAssertFalse(observation.playable)
        XCTAssertTrue(observation.paused)
        XCTAssertFalse(observation.gameOver)
        XCTAssertEqual(observation.board.width, Board.width)
        XCTAssertEqual(observation.board.height, Board.height)
        XCTAssertEqual(observation.board.cells[0][0], 3)
        XCTAssertEqual(observation.active?.kind, .t)
        XCTAssertEqual(observation.active?.rotation, .east)
        XCTAssertEqual(observation.active?.x, 4)
        XCTAssertEqual(observation.active?.y, 0)
        XCTAssertEqual(observation.next, .i)
        XCTAssertEqual(observation.nextQueue.count, 5)
        XCTAssertEqual(observation.hold, .z)
        XCTAssertEqual(observation.score, 1200)
        XCTAssertEqual(observation.level, 2)
        XCTAssertEqual(observation.lines, 17)
    }
}
