import XCTest
@testable import UI
@testable import Core

final class SoundEventKindTests: XCTestCase {
    func testSoundEventKindFromEvent() {
        XCTAssertEqual(SoundEventKind.from(event: .move), .move)
        XCTAssertEqual(SoundEventKind.from(event: .lineClear(2)), .lineClear)
    }
}
