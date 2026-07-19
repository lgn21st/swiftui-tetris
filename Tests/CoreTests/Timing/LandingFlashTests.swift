import Testing
@testable import Core

@Suite struct LandingFlashTests {
    @Test func testHardDropSetsLandingFlashBlocks() {
        var state = GameState(config: GameConfig())
        state.apply(action: .hardDrop)
        #expect(state.landingFlashTimerMs == GameConstants.landingFlashDurationMs)
        #expect(state.landingFlashBlocks.count == 4)
        for (x, y) in state.landingFlashBlocks {
            #expect(state.board.cells[y][x].filled)
        }
    }
}
