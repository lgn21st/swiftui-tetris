import XCTest
@testable import UI
@testable import Core

final class InputFlowTests: XCTestCase {
    func testInputEngineAppliesActions() {
        var state = GameState(config: GameConfig(), seed: 1)
        let engine = InputEngine()
        engine.apply(action: .moveRight, to: &state)
        XCTAssertEqual(state.active.x, 4)
    }
}
