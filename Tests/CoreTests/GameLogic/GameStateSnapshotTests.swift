import Testing
@testable import Core

@Suite struct GameStateSnapshotTests {
    @Test func testSnapshotCopiesCoreFields() {
        var state = GameState(config: GameConfig())
        state.paused = true
        state.gameOver = true
        state.setTimersForTesting(dropTimerMs: 320)
        state.applyLineClear(cleared: 1, clearedRows: [18], tSpin: .full)
        state.score = 1200
        state.level = 3
        state.lines = 15
        state.setTimersForTesting(landingFlashTimerMs: 60)
        state.landingFlashBlocks = [(4, 10)]
        state.softDropActive = true
        state.activeMovedSinceSpawn = true

        let snapshot = state.snapshot()

        #expect(snapshot.score == 1200)
        #expect(snapshot.level == 3)
        #expect(snapshot.lines == 15)
        #expect(snapshot.paused)
        #expect(snapshot.gameOver)
        #expect(snapshot.dropTimerMs == 320)
        #expect(snapshot.lineClearTimerMs == GameConstants.lineClearPauseMs)
        #expect(snapshot.lineClearRows == [18])
        #expect(snapshot.lineClearScore == 40)
        #expect(snapshot.lastLineClearTSpin == .full)
        #expect(snapshot.landingFlashTimerMs == 60)
        assertBlocksEqual(snapshot.landingFlashBlocks, [(4, 10)])
        #expect(snapshot.softDropActive)
        #expect(snapshot.activeMovedSinceSpawn)
    }

    @Test func testSnapshotIncludesGhostBlocks() {
        var state = GameState(config: GameConfig())
        state.active = Tetromino(kind: .i, x: 3, y: 0)
        state.updateGhostCache()

        let snapshot = state.snapshot()

        assertBlocksEqual(snapshot.ghostBlocks, state.ghostBlocks())
    }

    @Test func testLogicalStepAdvancesAtTransitionStartAndSurvivesRestart() {
        var state = GameState(config: GameConfig(), seed: 1)
        #expect(state.snapshot().logicalStep == 0)

        state.beginFixedStep()
        #expect(state.snapshot().logicalStep == 1)

        state.restart(seed: 2)
        #expect(state.snapshot().logicalStep == 1)
    }

    @Test func testSnapshotCarriesBoundedCausallyOrderedLockEvents() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.beginFixedStep()

        for _ in 0..<5 {
            state.apply(action: .hardDrop)
        }

        let events = state.snapshot().transitionEvents
        #expect(events.count == 4)
        let allLocked = events.allSatisfy { $0.locked }
        #expect(allLocked)
    }

    private func assertBlocksEqual(_ lhs: [(Int, Int)], _ rhs: [(Int, Int)]) {
        #expect(lhs.count == rhs.count)
        for (index, value) in lhs.enumerated() {
            #expect(value.0 == rhs[index].0)
            #expect(value.1 == rhs[index].1)
        }
    }
}
