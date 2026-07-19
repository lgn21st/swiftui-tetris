import Testing
@testable import UI

@Suite @MainActor struct DiagnosticsTrackerTests {
    @Test func testDiagnosticsTrackerUpdatesFpsAfterWindow() {
        var tracker = DiagnosticsTracker()
        var state = DiagnosticsState.empty
        for _ in 0..<60 {
            state = tracker.recordFrame(elapsedMs: 16)
        }
        #expect(state.fpsText == "FPS: --")
        state = tracker.recordFrame(elapsedMs: 40)
        #expect(state.tickText == "Tick: 40ms")
        let parts = state.fpsText.split(separator: " ")
        let fpsValue = Int(parts.last ?? "") ?? 0
        #expect((60...62).contains(fpsValue))
    }

    @Test func testSceneDriverUpdatesDiagnosticsFromFrame() {
        let driver = SceneDriver()
        driver.scene.update(1.0)
        driver.scene.update(1.05)
        driver.scene.update(1.10)
        driver.scene.update(1.15)
        driver.scene.update(1.20)
        #expect(driver.diagnosticsState.tickText == "Tick: 50ms")
    }
}
