import Foundation

public protocol KeyValueStoring {
    func data(forKey key: String) -> Data?
    func setData(_ data: Data?, forKey key: String)
}

extension UserDefaults: KeyValueStoring {
    public func setData(_ data: Data?, forKey key: String) {
        set(data, forKey: key)
    }
}

public protocol WindowStateStoring {
    func load() -> WindowState?
    func save(_ state: WindowState)
}

public final class UserDefaultsWindowStateStore: WindowStateStoring {
    private let storage: KeyValueStoring
    private let key: String

    public init(storage: KeyValueStoring = UserDefaults.standard, key: String = "swiftui-teris.window") {
        self.storage = storage
        self.key = key
    }

    public func load() -> WindowState? {
        guard let data = storage.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(WindowState.self, from: data)
    }

    public func save(_ state: WindowState) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(state) else { return }
        storage.setData(data, forKey: key)
    }
}
