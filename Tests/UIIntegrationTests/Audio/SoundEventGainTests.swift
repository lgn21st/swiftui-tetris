import Testing
@testable import UI
@testable import Core

@Suite struct SoundEventGainTests {
    @Test func testSoundEventGainMapping() {
        #expect(SoundEventMapper.gain(for: SoundEvent.move) == 0.2)
        #expect(SoundEventMapper.gain(for: SoundEvent.rotate) == 0.3)
        #expect(SoundEventMapper.gain(for: SoundEvent.softDrop) == 0.2)
        #expect(SoundEventMapper.gain(for: SoundEvent.hardDrop) == 0.4)
        #expect(SoundEventMapper.gain(for: SoundEvent.hold) == 0.35)
        #expect(SoundEventMapper.gain(for: SoundEvent.lineClear(1)) == 0.5)
        #expect(SoundEventMapper.gain(for: SoundEvent.lineClear(4)) == 0.8)
        #expect(SoundEventMapper.gain(for: SoundEvent.gameOver) == 0.6)
    }
}
