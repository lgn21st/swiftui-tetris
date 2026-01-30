import XCTest
import Core
@testable import Adapter

final class ObservationMappingTests: XCTestCase {
    func testMapsSnapshotToObservation() {
        var state = GameState(config: GameConfig(), seed: 7)
        state.score = 1200
        state.level = 2
        state.lines = 17
        state.hold = .z
        state.canHold = true
        state.nextQueue = [.i, .o]
        state.active = Tetromino(kind: .t, x: 4, y: 0)
        state.active.rotation = .east
        state.board.cells[0][0] = Cell(filled: true, kind: .t)

        let snapshot = state.snapshot()
        let observation = ObservationMapper.map(snapshot: snapshot, seq: 42, tsMs: 1700000000000)

        XCTAssertTrue(observation.playable)
        XCTAssertEqual(observation.board.width, Board.width)
        XCTAssertEqual(observation.board.height, Board.height)
        XCTAssertEqual(observation.board.cells[0][0], 1)
        XCTAssertEqual(observation.board.kinds[0][0], .t)
        XCTAssertEqual(observation.active?.kind, .t)
        XCTAssertEqual(observation.active?.rotation, .east)
        XCTAssertEqual(observation.active?.x, 4)
        XCTAssertEqual(observation.active?.y, 0)
        XCTAssertEqual(observation.next, .i)
        XCTAssertEqual(observation.hold, .z)
        XCTAssertEqual(observation.score, 1200)
        XCTAssertEqual(observation.level, 2)
        XCTAssertEqual(observation.lines, 17)
    }
}
