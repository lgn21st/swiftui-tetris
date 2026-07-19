import Testing
@testable import Core

@Suite struct LockResetTests {
    @Test func testGroundedMoveResetsLockTimerUntilLimit() {
        var config = GameConfig()
        config.lockDelayMs = 1000
        config.lockResetLimit = 1
        var state = GameState(config: config, seed: 1)
        state.active = Tetromino(kind: .o, x: 0, y: Board.height - 2)
        state.setTimersForTesting(lockTimerMs: 900)

        state.apply(action: .moveRight)
        #expect(state.lockTimerMs == 0)
        #expect(state.lockResetCount == 1)

        state.setTimersForTesting(lockTimerMs: 900)
        state.apply(action: .moveLeft)
        #expect(state.lockTimerMs == 900)
    }
}
