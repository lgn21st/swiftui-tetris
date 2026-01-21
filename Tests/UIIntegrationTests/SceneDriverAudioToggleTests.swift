import XCTest
@testable import UI
@testable import Core

final class SceneDriverAudioToggleTests: XCTestCase {
    private final class MemoryStore: SettingsStoring {
        var loaded: SettingsState

        init(settings: SettingsState) {
            self.loaded = settings
        }

        func load() -> SettingsState {
            loaded
        }

        func save(_ settings: SettingsState) {}
    }

    private final class SpyAudio: AudioPlaying {
        var events: [SoundEvent] = []

        func play(_ event: SoundEvent, masterVolume: Double, gainOverride: Double?) {
            events.append(event)
        }
    }

    func testSceneDriverSkipsDisabledSfx() {
        var settings = SettingsState()
        settings.setSfxEnabled(false, for: .move)
        let store = MemoryStore(settings: settings)
        let spy = SpyAudio()
        let driver = SceneDriver(audio: spy, settingsStore: store)
        driver.commandStartGame()

        driver.handleKeyDown("left")
        driver.tick(elapsedMs: 16)

        XCTAssertFalse(spy.events.contains(.move))
    }

    func testSceneDriverPlaysEnabledSfx() {
        let settings = SettingsState()
        let store = MemoryStore(settings: settings)
        let spy = SpyAudio()
        let driver = SceneDriver(audio: spy, settingsStore: store)
        driver.commandStartGame()

        driver.handleKeyDown("left")
        driver.tick(elapsedMs: 16)

        XCTAssertTrue(spy.events.contains(.move))
    }
}
