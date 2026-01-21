import XCTest
@testable import UI
@testable import Core

final class SoundEventGainTests: XCTestCase {
    func testSoundEventGainMapping() {
        XCTAssertEqual(SoundEventMapper.gain(for: SoundEvent.move), 0.2)
        XCTAssertEqual(SoundEventMapper.gain(for: SoundEvent.rotate), 0.3)
        XCTAssertEqual(SoundEventMapper.gain(for: SoundEvent.softDrop), 0.2)
        XCTAssertEqual(SoundEventMapper.gain(for: SoundEvent.hardDrop), 0.4)
        XCTAssertEqual(SoundEventMapper.gain(for: SoundEvent.hold), 0.35)
        XCTAssertEqual(SoundEventMapper.gain(for: SoundEvent.lineClear(1)), 0.5)
        XCTAssertEqual(SoundEventMapper.gain(for: SoundEvent.lineClear(4)), 0.8)
        XCTAssertEqual(SoundEventMapper.gain(for: SoundEvent.gameOver), 0.6)
    }
}
