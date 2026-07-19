import Testing
@testable import UI

@Suite struct OverlayStateTests {
    @Test func testOverlayShowsPaused() {
        let overlay = OverlayState(isPaused: true, isGameOver: false, isTitle: false)
        #expect(overlay.title == "Paused")
    }

    @Test func testOverlayShowsGameOver() {
        let overlay = OverlayState(isPaused: false, isGameOver: true, isTitle: false)
        #expect(overlay.title == "Game Over")
    }

    @Test func testOverlayShowsStartHintOnTitle() {
        let overlay = OverlayState(isPaused: false, isGameOver: false, isTitle: true)
        #expect(overlay.message == "Press Space or Enter to start")
    }

    @Test func testOverlayShowsPausedHint() {
        let overlay = OverlayState(isPaused: true, isGameOver: false, isTitle: false)
        #expect(overlay.message == "Press P to resume · R to restart")
    }

    @Test func testOverlayShowsGameOverHint() {
        let overlay = OverlayState(isPaused: false, isGameOver: true, isTitle: false)
        #expect(overlay.message == "Press R to restart")
    }

    @Test func testOverlayBlinksStartHintOnTitle() {
        let overlay = OverlayState(isPaused: false, isGameOver: false, isTitle: true)
        #expect(overlay.shouldBlinkStartHint)
        let paused = OverlayState(isPaused: true, isGameOver: false, isTitle: false)
        #expect(!paused.shouldBlinkStartHint)
    }
}
