import XCTest
@testable import Core

final class LockResetTests: XCTestCase {
    func testGroundedMoveResetsLockTimerUntilLimit() {
        var config = GameConfig()
        config.lockDelayMs = 1000
        config.lockResetLimit = 1
        var state = GameState(config: config, seed: 1)
        state.active = Tetromino(kind: .o, x: 0, y: Board.height - 2)
        state.lockTimerMs = 900

        state.apply(action: .moveRight)
        XCTAssertEqual(state.lockTimerMs, 0)
        XCTAssertEqual(state.lockResetCount, 1)

        state.lockTimerMs = 900
        state.apply(action: .moveLeft)
        XCTAssertEqual(state.lockTimerMs, 900)
    }
}
