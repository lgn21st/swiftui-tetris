import XCTest
@testable import UI
@testable import Core

final class SoundEventGainTests: XCTestCase {
    func testSoundEventGainMapping() {
        XCTAssertEqual(SoundEventMapper.gain(for: .move), 0.2)
        XCTAssertEqual(SoundEventMapper.gain(for: .rotate), 0.3)
        XCTAssertEqual(SoundEventMapper.gain(for: .softDrop), 0.2)
        XCTAssertEqual(SoundEventMapper.gain(for: .hardDrop), 0.4)
        XCTAssertEqual(SoundEventMapper.gain(for: .hold), 0.35)
        XCTAssertEqual(SoundEventMapper.gain(for: .lineClear(1)), 0.5)
        XCTAssertEqual(SoundEventMapper.gain(for: .lineClear(4)), 0.8)
        XCTAssertEqual(SoundEventMapper.gain(for: .gameOver), 0.6)
    }
}
