import XCTest
@testable import Core

final class QueueRngTests: XCTestCase {
    func testRefillBagAddsSevenUnique() {
        var rng = SimpleRng(seed: 1)
        var queue: [TetrominoType] = []
        QueueRng.refillBag(rng: &rng, queue: &queue)
        XCTAssertEqual(queue.count, 7)
        XCTAssertEqual(Set(queue).count, 7)
    }

    func testEnsureQueueMaintainsMinimum() {
        var rng = SimpleRng(seed: 2)
        var queue: [TetrominoType] = [.i]
        QueueRng.ensureQueue(rng: &rng, queue: &queue, minimum: 1)
        XCTAssertGreaterThanOrEqual(queue.count, 1)
    }
}
