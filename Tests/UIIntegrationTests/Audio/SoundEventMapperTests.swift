import Testing
@testable import UI
@testable import Core

@Suite struct SoundEventMapperTests {
    @Test func testSoundEventMapsToFileName() {
        #expect(SoundEventMapper.fileName(for: .move) == "move.wav")
        #expect(SoundEventMapper.fileName(for: .lineClear(2)) == "line_clear_2.wav")
    }
}
