import XCTest
@testable import Core

final class GameConstantsTests: XCTestCase {
    func testDefaultsMatchExpectedValues() {
        XCTAssertEqual(GameConstants.tickMs, 16)
        XCTAssertEqual(GameConstants.softDropMultiplier, 10)
        XCTAssertEqual(GameConstants.lockDelayMs, 450)
        XCTAssertEqual(GameConstants.lockResetLimit, 15)
        XCTAssertEqual(GameConstants.baseDropMs, 1000)
        XCTAssertEqual(GameConstants.softDropGraceMs, 150)
        XCTAssertEqual(GameConstants.landingFlashDurationMs, 120)
        XCTAssertEqual(GameConstants.lineClearPauseMs, 180)
        XCTAssertEqual(GameConstants.defaultDasMs, 150)
        XCTAssertEqual(GameConstants.defaultArrMs, 50)
        XCTAssertEqual(GameConstants.minimumDropMs, 100)
        XCTAssertEqual(GameConstants.dropTableFallbackMs, 120)
    }

    func testDropTableHasExpectedEntries() {
        XCTAssertEqual(GameConstants.dropTable.count, 9)
        XCTAssertEqual(GameConstants.dropTable.first, 1000)
        XCTAssertEqual(GameConstants.dropTable.last, 160)
    }
}
