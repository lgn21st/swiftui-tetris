import Testing
@testable import UI

@Suite struct GameLoopTests {
    @Test func testGameLoopReturnsRenderState() {
        let loop = GameLoop()
        let renderState = loop.stepFrame(elapsedMs: 0)
        #expect(!renderState.activeBlocks.isEmpty)
    }
}
