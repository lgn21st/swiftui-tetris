import XCTest
@testable import Adapter

final class InMemoryTransportTests: XCTestCase {
    func testCommandsAreDeliveredInOrder() {
        let transport = InMemoryTransport()
        let first = TetrisAICommand.action(actions: [.rotateCw, .moveLeft])
        let second = TetrisAICommand.action(actions: [.hardDrop])

        transport.enqueueCommand(first)
        transport.enqueueCommand(second)

        XCTAssertEqual(transport.dequeueCommand(), first)
        XCTAssertEqual(transport.dequeueCommand(), second)
        XCTAssertNil(transport.dequeueCommand())
    }

    func testObservationsAreDeliveredInOrder() {
        let transport = InMemoryTransport()
        let obs1 = TetrisAIObservation(
            seq: 1,
            tsMs: 1000,
            playable: true,
            paused: false,
            gameOver: false,
            board: .empty(),
            active: nil,
            next: nil,
            hold: nil,
            score: 0,
            level: 0,
            lines: 0,
            timers: .init(dropMs: 0, lockMs: 0, lineClearMs: 0)
        )
        let obs2 = TetrisAIObservation(
            seq: 2,
            tsMs: 1100,
            playable: false,
            paused: true,
            gameOver: false,
            board: .empty(),
            active: nil,
            next: nil,
            hold: nil,
            score: 10,
            level: 1,
            lines: 2,
            timers: .init(dropMs: 0, lockMs: 0, lineClearMs: 0)
        )

        transport.enqueueObservation(obs1)
        transport.enqueueObservation(obs2)

        XCTAssertEqual(transport.dequeueObservation(), obs1)
        XCTAssertEqual(transport.dequeueObservation(), obs2)
        XCTAssertNil(transport.dequeueObservation())
    }
}
