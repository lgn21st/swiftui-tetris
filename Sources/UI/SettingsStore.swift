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

public protocol SettingsStoring {
    func load() -> SettingsState
    func save(_ settings: SettingsState)
}

public final class UserDefaultsSettingsStore: SettingsStoring {
    private let storage: KeyValueStoring
    private let key: String

    public init(storage: KeyValueStoring = UserDefaults.standard, key: String = "swiftui-teris.settings") {
        self.storage = storage
        self.key = key
    }

    public func load() -> SettingsState {
        guard let data = storage.data(forKey: key) else { return SettingsState() }
        let decoder = JSONDecoder()
        return (try? decoder.decode(SettingsState.self, from: data)) ?? SettingsState()
    }

    public func save(_ settings: SettingsState) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(settings) else { return }
        storage.setData(data, forKey: key)
    }
}
