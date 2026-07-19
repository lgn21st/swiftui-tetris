import Testing
@testable import Core

@Suite struct HoldTests {
    @Test func testHoldStoresCurrentPieceAndSpawnsNext() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.nextQueue = [.t]
        let didHold = state.holdAction()
        #expect(didHold)
        #expect(state.hold == .i)
        #expect(state.active.kind == .t)
        #expect(!state.canHold)
    }

    @Test func testHoldSwapsWhenAlreadyHeld() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .o, x: 3, y: 0)
        state.hold = .t
        state.canHold = true
        let didHold = state.holdAction()
        #expect(didHold)
        #expect(state.hold == .o)
        #expect(state.active.kind == .t)
        #expect(!state.canHold)
    }

    @Test func testHoldOnlyOncePerSpawn() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .l, x: 3, y: 0)
        state.nextQueue = [.j]
        let firstHold = state.holdAction()
        let secondHold = state.holdAction()
        #expect(firstHold)
        #expect(!secondHold)
        #expect(state.hold == .l)
        #expect(state.active.kind == .j)
    }
}
