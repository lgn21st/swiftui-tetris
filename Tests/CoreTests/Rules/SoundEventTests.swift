import Testing
@testable import Core

@Suite struct SoundEventTests {
    @Test func testSoundEventsEmittedOnActions() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.apply(action: .moveLeft)
        state.apply(action: .rotateCw)
        state.apply(action: .softDrop)
        let events = state.takeSoundEvents()
        #expect(events.contains(.move))
        #expect(events.contains(.rotate))
        #expect(events.contains(.softDrop))
    }
}
