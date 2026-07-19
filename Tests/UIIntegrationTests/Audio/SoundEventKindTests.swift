import Testing
@testable import UI
@testable import Core

@Suite struct SoundEventKindTests {
    @Test func testSoundEventKindFromEvent() {
        #expect(SoundEventKind.from(event: .move) == .move)
        #expect(SoundEventKind.from(event: .lineClear(2)) == .lineClear)
    }
}
