import XCTest
@testable import UI
@testable import Core

final class AudioEventTests: XCTestCase {
    func testAudioPlaysMoveEvent() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.apply(action: .moveLeft)
        let events = state.takeSoundEvents()
        XCTAssertTrue(events.contains(.move))
    }
}
