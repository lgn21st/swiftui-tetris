import Testing
@testable import Core

@Suite struct TimingTests {
    @Test func testDropIntervalTableAndFloor() {
        #expect((Timing.dropInterval(
                level: 0,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            )) == (GameConstants.dropTable[0]))
        #expect((Timing.dropInterval(
                level: 1,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            )) == (GameConstants.dropTable[1]))
        #expect((Timing.dropInterval(
                level: 8,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            )) == (GameConstants.dropTable[8]))
        #expect((Timing.dropInterval(
                level: 9,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            )) == (GameConstants.dropTableFallbackMs))
    }

    @Test func testDropIntervalClampsToBaseAndMinimum() {
        #expect((Timing.dropInterval(
                level: 0,
                baseDropMs: 900,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            )) == (900))
        #expect((Timing.dropInterval(
                level: 0,
                baseDropMs: 50,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            )) == (GameConstants.minimumDropMs))
    }

    @Test func testSoftDropIntervalUsesMultiplier() {
        #expect((Timing.dropInterval(
                level: 0,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: true,
                softDropMultiplier: GameConstants.softDropMultiplier
            )) == (GameConstants.minimumDropMs))
        #expect((Timing.dropInterval(
                level: 0,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: true,
                softDropMultiplier: 0
            )) == (GameConstants.baseDropMs))
    }
}
