import Testing
@testable import Core

@Suite struct QueueRngTests {
    @Test func testRefillBagAppendsTwoPieces() {
        var rng = SimpleRng(seed: 1)
        var queue: [TetrominoType] = []
        QueueRng.refillBag(rng: &rng, queue: &queue)
        #expect(queue.count == 2)
    }
}
