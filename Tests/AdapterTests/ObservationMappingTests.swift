import Testing
import Foundation
import Core
@testable import Adapter

@Suite struct ObservationMappingTests {
    @Test func testMapsSnapshotToObservation() {
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

        #expect(observation.logicalStep == snapshot.logicalStep)
        #expect(observation.events == [])
        #expect(!observation.playable)
        #expect(observation.paused)
        #expect(!observation.gameOver)
        #expect(observation.board.width == Board.width)
        #expect(observation.board.height == Board.height)
        #expect(observation.board.cells[0][0] == 3)
        #expect(observation.active?.kind == .t)
        #expect(observation.active?.rotation == .east)
        #expect(observation.active?.x == 4)
        #expect(observation.active?.y == 0)
        #expect(observation.next == .i)
        #expect(observation.nextQueue.count == 5)
        #expect(observation.hold == .z)
        #expect(observation.score == 1200)
        #expect(observation.level == 2)
        #expect(observation.lines == 17)
    }

    @Test func testMapsOrderedTransitionEventsWithoutLegacyLastEvent() throws {
        var state = GameState(config: GameConfig(), seed: 1)
        state.beginFixedStep()
        state.apply(action: .hardDrop)

        let observation = ObservationMapper.map(snapshot: state.snapshot(), seq: 1, tsMs: 1)
        #expect(observation.events.count == 1)
        #expect(observation.events[0].locked)

        let data = try WireCodec.encode(.observation(observation))
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(object["events"] != nil)
        #expect(object["logical_step"] != nil)
        #expect(object["last_event"] == nil)
    }
}
