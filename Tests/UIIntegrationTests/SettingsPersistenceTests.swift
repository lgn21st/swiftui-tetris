import XCTest
@testable import UI

final class SettingsPersistenceTests: XCTestCase {
    private final class MemoryStore: KeyValueStoring {
        private var values: [String: Data] = [:]

        func data(forKey key: String) -> Data? {
            values[key]
        }

        func setData(_ data: Data?, forKey key: String) {
            values[key] = data
        }
    }

    func testSettingsStoreDefaultsWhenEmpty() {
        let storage = MemoryStore()
        let store = UserDefaultsSettingsStore(storage: storage, key: "test")
        let settings = store.load()
        XCTAssertEqual(settings, SettingsState())
    }

    func testSettingsStoreSavesAndLoads() {
        let storage = MemoryStore()
        let store = UserDefaultsSettingsStore(storage: storage, key: "test")
        var settings = SettingsState()
        settings.volume = 0.5
        settings.muted = true
        settings.setInputDas(120)
        settings.setInputArr(40)
        settings.setSoftDropArr(30)
        settings.setGain(0.9, for: .hardDrop)
        settings.setSfxEnabled(false, for: .softDrop)
        store.save(settings)
        let loaded = store.load()
        XCTAssertEqual(loaded, settings)
    }
}
