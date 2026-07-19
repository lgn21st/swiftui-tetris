import Testing
@testable import UI
@testable import Core

@Suite struct AudioEventTests {
    @Test func testAudioPlaysMoveEvent() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.apply(action: .moveLeft)
        let events = state.takeSoundEvents()
        #expect(events.contains(.move))
    }
}
