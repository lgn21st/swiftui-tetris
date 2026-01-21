import XCTest
@testable import UI
@testable import Core

final class SoundEventMapperTests: XCTestCase {
    func testSoundEventMapsToFileName() {
        XCTAssertEqual(SoundEventMapper.fileName(for: .move), "move.wav")
        XCTAssertEqual(SoundEventMapper.fileName(for: .lineClear(2)), "line_clear_2.wav")
    }
}
