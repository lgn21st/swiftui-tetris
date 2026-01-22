import XCTest
@testable import Core

final class QueueRngTests: XCTestCase {
    func testRefillBagAppendsTwoPieces() {
        var rng = SimpleRng(seed: 1)
        var queue: [TetrominoType] = []
        QueueRng.refillBag(rng: &rng, queue: &queue)
        XCTAssertEqual(queue.count, 2)
    }
}
