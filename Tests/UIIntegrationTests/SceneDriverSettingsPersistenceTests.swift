import XCTest
@testable import UI

final class SceneDriverSettingsPersistenceTests: XCTestCase {
    private final class MemoryStore: SettingsStoring {
        var loaded = SettingsState()
        var saved: [SettingsState] = []

        func load() -> SettingsState {
            loaded
        }

        func save(_ settings: SettingsState) {
            saved.append(settings)
        }
    }

    func testSceneDriverLoadsSettings() {
        let store = MemoryStore()
        store.loaded = SettingsState(volume: 0.3, muted: true)
        let driver = SceneDriver(settingsStore: store)
        XCTAssertEqual(driver.settings.volume, 0.3)
        XCTAssertEqual(driver.settings.muted, true)
    }

    func testSceneDriverPersistsSettingsUpdates() {
        let store = MemoryStore()
        let driver = SceneDriver(settingsStore: store)
        driver.settings.volume = 0.2
        driver.settings.muted = true
        XCTAssertEqual(store.saved.last, driver.settings)
    }
}
