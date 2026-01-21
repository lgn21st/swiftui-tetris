import XCTest
@testable import Core

final class TimingTests: XCTestCase {
    func testDropIntervalTableAndFloor() {
        XCTAssertEqual(
            Timing.dropInterval(
                level: 0,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            ),
            GameConstants.dropTable[0]
        )
        XCTAssertEqual(
            Timing.dropInterval(
                level: 1,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            ),
            GameConstants.dropTable[1]
        )
        XCTAssertEqual(
            Timing.dropInterval(
                level: 8,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            ),
            GameConstants.dropTable[8]
        )
        XCTAssertEqual(
            Timing.dropInterval(
                level: 9,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            ),
            GameConstants.dropTableFallbackMs
        )
    }

    func testDropIntervalClampsToBaseAndMinimum() {
        XCTAssertEqual(
            Timing.dropInterval(
                level: 0,
                baseDropMs: 900,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            ),
            900
        )
        XCTAssertEqual(
            Timing.dropInterval(
                level: 0,
                baseDropMs: 50,
                softDrop: false,
                softDropMultiplier: GameConstants.softDropMultiplier
            ),
            GameConstants.minimumDropMs
        )
    }

    func testSoftDropIntervalUsesMultiplier() {
        XCTAssertEqual(
            Timing.dropInterval(
                level: 0,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: true,
                softDropMultiplier: GameConstants.softDropMultiplier
            ),
            GameConstants.minimumDropMs
        )
        XCTAssertEqual(
            Timing.dropInterval(
                level: 0,
                baseDropMs: GameConstants.baseDropMs,
                softDrop: true,
                softDropMultiplier: 0
            ),
            GameConstants.baseDropMs
        )
    }
}
