import Testing
@testable import Renderer

@Suite struct TetrisSceneClockTests {
    @Test func testSceneAdvancesFixedSteps() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var totalSteps = 0
        scene.onFixedStep = { totalSteps += $0 }

        scene.update(1.0)
        scene.update(1.016)

        #expect(totalSteps == 1)
    }

    @Test func testSceneClampsLargeDelta() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var totalSteps = 0
        scene.onFixedStep = { totalSteps += $0 }

        scene.update(1.0)
        scene.update(2.0)

        #expect(totalSteps == 6)
    }

    @Test func testSceneReportsFrameDelta() {
        let scene = TetrisScene(size: TetrisScene.defaultSize, stepMs: 16, maxDeltaMs: 100)
        var lastFrameMs = 0
        scene.onFrame = { lastFrameMs = $0 }

        scene.update(1.0)
        scene.update(1.02)

        #expect(lastFrameMs == 20)
    }
}
