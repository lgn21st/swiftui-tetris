import XCTest
@testable import UI

final class GameLoopTests: XCTestCase {
    func testGameLoopReturnsRenderState() {
        let loop = GameLoop()
        let renderState = loop.step(elapsedMs: 0)
        XCTAssertFalse(renderState.activeBlocks.isEmpty)
    }
}
