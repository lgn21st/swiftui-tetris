import Testing
@testable import Core

@Suite struct InputRepeatTests {
    @Test func testPressReturnsTrueOnce() {
        var state = RepeatState()
        let firstPress = state.press()
        let secondPress = state.press()
        #expect(firstPress)
        #expect(!secondPress)
    }

    @Test func testRepeatAfterDasAndArr() {
        var state = RepeatState()
        let config = RepeatConfig(dasMs: GameConstants.defaultDasMs, arrMs: GameConstants.defaultArrMs)
        _ = state.press()

        #expect(state.tick(elapsedMs: 149, config: config) == 0)
        #expect(state.tick(elapsedMs: 1, config: config) == 0)
        #expect(state.tick(elapsedMs: 50, config: config) == 1)
        #expect(state.tick(elapsedMs: 50, config: config) == 1)
    }

    @Test func testReleaseResetsState() {
        var state = RepeatState()
        let config = RepeatConfig(dasMs: GameConstants.defaultDasMs, arrMs: GameConstants.defaultArrMs)
        _ = state.press()
        _ = state.tick(elapsedMs: 200, config: config)
        state.release()
        #expect(state.tick(elapsedMs: 200, config: config) == 0)
    }

    @Test func testSyncHeldResetsRepeatCounters() {
        var state = RepeatState()
        let config = RepeatConfig(dasMs: 0, arrMs: 50)
        _ = state.press()
        #expect(state.tick(elapsedMs: 200, config: config) == 4)
        state.syncHeld(true)
        #expect(state.tick(elapsedMs: 50, config: config) == 1)
    }
}
