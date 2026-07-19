import Testing
@testable import Adapter

@Suite struct InMemoryTransportTests {
    private func defaultEvent() -> TetrisAIEvent {
        TetrisAIEvent(
            locked: false,
            linesCleared: 0,
            lineClearScore: 0,
            tspin: nil,
            combo: -1,
            backToBack: false
        )
    }

    @Test func testCommandsAreDeliveredInOrder() {
        let transport = InMemoryTransport()
        let first = TetrisAICommand.action(actions: [.rotateCw, .moveLeft])
        let second = TetrisAICommand.action(actions: [.hardDrop])

        transport.enqueueCommand(first)
        transport.enqueueCommand(second)

        #expect(transport.dequeueCommand() == first)
        #expect(transport.dequeueCommand() == second)
        #expect(transport.dequeueCommand() == nil)
    }

    @Test func testObservationsAreDeliveredInOrder() {
        let transport = InMemoryTransport()
        let obs1 = TetrisAIObservation(
            seq: 1,
            tsMs: 1000,
            logicalStep: 1,
            playable: true,
            paused: false,
            gameOver: false,
            episodeId: 0,
            seed: 1,
            pieceId: 1,
            stepInPiece: 0,
            board: .empty(),
            boardId: 0,
            active: nil,
            ghostY: nil,
            next: .i,
            nextQueue: [.i, .o, .t, .s, .z],
            hold: nil,
            canHold: true,
            events: [defaultEvent()],
            stateHash: "",
            score: 0,
            level: 0,
            lines: 0,
            timers: .init(dropMs: 0, lockMs: 0, lineClearMs: 0)
        )
        let obs2 = TetrisAIObservation(
            seq: 2,
            tsMs: 1100,
            logicalStep: 2,
            playable: false,
            paused: true,
            gameOver: false,
            episodeId: 0,
            seed: 1,
            pieceId: 1,
            stepInPiece: 1,
            board: .empty(),
            boardId: 0,
            active: nil,
            ghostY: nil,
            next: .i,
            nextQueue: [.i, .o, .t, .s, .z],
            hold: nil,
            canHold: true,
            events: [],
            stateHash: "",
            score: 10,
            level: 1,
            lines: 2,
            timers: .init(dropMs: 0, lockMs: 0, lineClearMs: 0)
        )

        transport.enqueueObservation(obs1)
        transport.enqueueObservation(obs2)

        #expect(transport.dequeueObservation() == obs1)
        #expect(transport.dequeueObservation() == obs2)
        #expect(transport.dequeueObservation() == nil)
    }
}
