import XCTest
@testable import Renderer

final class TetrisSceneClockTests: XCTestCase {
    func testSceneAdvancesFixedSteps() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var totalSteps = 0
        scene.onFixedStep = { totalSteps += $0 }

        scene.update(1.0)
        scene.update(1.016)

        XCTAssertEqual(totalSteps, 1)
    }

    func testSceneClampsLargeDelta() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var totalSteps = 0
        scene.onFixedStep = { totalSteps += $0 }

        scene.update(1.0)
        scene.update(2.0)

        XCTAssertEqual(totalSteps, 6)
    }

    func testSceneReportsFrameDelta() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var lastFrameMs = 0
        scene.onFrame = { lastFrameMs = $0 }

        scene.update(1.0)
        scene.update(1.02)

        XCTAssertEqual(lastFrameMs, 20)
    }
}
