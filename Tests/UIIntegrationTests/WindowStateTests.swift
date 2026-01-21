import XCTest
@testable import UI

final class WindowStateTests: XCTestCase {
    private final class MemoryStore: KeyValueStoring {
        private var values: [String: Data] = [:]

        func data(forKey key: String) -> Data? {
            values[key]
        }

        func setData(_ data: Data?, forKey key: String) {
            values[key] = data
        }
    }

    func testWindowStateStoreDefaultsToNil() {
        let storage = MemoryStore()
        let store = UserDefaultsWindowStateStore(storage: storage, key: "test.window")
        XCTAssertNil(store.load())
    }

    func testWindowStateStoreRoundTrip() {
        let storage = MemoryStore()
        let store = UserDefaultsWindowStateStore(storage: storage, key: "test.window")
        let state = WindowState(x: 20, y: 30, width: 640, height: 480)
        store.save(state)
        let loaded = store.load()
        XCTAssertEqual(loaded, state)
    }

    func testWindowStateClampsToMinimumSize() {
        let state = WindowState(x: 0, y: 0, width: 100, height: 200)
        let clamped = state.clamped(minSize: CGSize(width: 300, height: 400))
        XCTAssertEqual(clamped.width, 300)
        XCTAssertEqual(clamped.height, 400)
    }
}
