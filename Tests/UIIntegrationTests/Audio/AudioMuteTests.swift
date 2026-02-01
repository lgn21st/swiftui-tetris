import XCTest
@testable import UI
@testable import Core

final class AudioMuteTests: XCTestCase {
    func testMuteToggleSuppressesPlaybackAndAmbientLoop() {
        let audio = RecordingAudio()
        let driver = SceneDriver(audio: audio)

        driver.start()
        XCTAssertEqual(audio.ambientEnabledStates, [true])

        driver.handleKeyDown("left")
        driver.tick(elapsedMs: 16)
        XCTAssertEqual(audio.playEvents.count, 1)

        driver.handleKeyDown("m")
        XCTAssertEqual(audio.ambientEnabledStates.last, false)

        driver.handleKeyDown("left")
        driver.tick(elapsedMs: 16)
        XCTAssertEqual(audio.playEvents.count, 1)

        driver.handleKeyDown("m")
        XCTAssertEqual(audio.ambientEnabledStates.last, true)

        driver.handleKeyDown("left")
        driver.tick(elapsedMs: 16)
        XCTAssertEqual(audio.playEvents.count, 2)
    }
}

private final class RecordingAudio: AudioPlaying {
    private(set) var playEvents: [SoundEvent] = []
    private(set) var ambientEnabledStates: [Bool] = []
    private(set) var ambientVolumes: [Double] = []
    private(set) var ambientDuckedStates: [Bool] = []

    func play(_ event: SoundEvent, masterVolume: Double, gainOverride: Double?) {
        playEvents.append(event)
    }

    func setAmbientLoop(enabled: Bool, masterVolume: Double) {
        ambientEnabledStates.append(enabled)
        ambientVolumes.append(masterVolume)
    }

    func setAmbientDucking(enabled: Bool) {
        ambientDuckedStates.append(enabled)
    }
}
