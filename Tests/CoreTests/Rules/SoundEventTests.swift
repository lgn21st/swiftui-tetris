import XCTest
@testable import Core

final class SoundEventTests: XCTestCase {
    func testSoundEventsEmittedOnActions() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.apply(action: .moveLeft)
        state.apply(action: .rotateCw)
        state.apply(action: .softDrop)
        let events = state.takeSoundEvents()
        XCTAssertTrue(events.contains(.move))
        XCTAssertTrue(events.contains(.rotate))
        XCTAssertTrue(events.contains(.softDrop))
    }
}
