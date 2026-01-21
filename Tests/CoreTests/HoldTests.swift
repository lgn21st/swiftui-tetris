import XCTest
@testable import Core

final class HoldTests: XCTestCase {
    func testHoldStoresCurrentPieceAndSpawnsNext() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.nextQueue = [.t]
        let didHold = state.holdAction()
        XCTAssertTrue(didHold)
        XCTAssertEqual(state.hold, .i)
        XCTAssertEqual(state.active.kind, .t)
        XCTAssertFalse(state.canHold)
    }

    func testHoldSwapsWhenAlreadyHeld() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .o, x: 3, y: 0)
        state.hold = .t
        state.canHold = true
        let didHold = state.holdAction()
        XCTAssertTrue(didHold)
        XCTAssertEqual(state.hold, .o)
        XCTAssertEqual(state.active.kind, .t)
        XCTAssertFalse(state.canHold)
    }

    func testHoldOnlyOncePerSpawn() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .l, x: 3, y: 0)
        state.nextQueue = [.j]
        XCTAssertTrue(state.holdAction())
        XCTAssertFalse(state.holdAction())
        XCTAssertEqual(state.hold, .l)
        XCTAssertEqual(state.active.kind, .j)
    }
}
