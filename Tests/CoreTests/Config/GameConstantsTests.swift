import Testing
@testable import Core

@Suite struct GameConstantsTests {
    @Test func testDefaultsMatchExpectedValues() {
        #expect(GameConstants.tickMs == 16)
        #expect(GameConstants.softDropMultiplier == 10)
        #expect(GameConstants.lockDelayMs == 450)
        #expect(GameConstants.lockResetLimit == 15)
        #expect(GameConstants.baseDropMs == 1000)
        #expect(GameConstants.softDropGraceMs == 150)
        #expect(GameConstants.landingFlashDurationMs == 120)
        #expect(GameConstants.lineClearPauseMs == 180)
        #expect(GameConstants.defaultDasMs == 150)
        #expect(GameConstants.defaultArrMs == 50)
        #expect(GameConstants.minimumDropMs == 100)
        #expect(GameConstants.dropTableFallbackMs == 120)
    }

    @Test func testDropTableHasExpectedEntries() {
        #expect(GameConstants.dropTable.count == 9)
        #expect(GameConstants.dropTable.first == 1000)
        #expect(GameConstants.dropTable.last == 160)
    }
}
