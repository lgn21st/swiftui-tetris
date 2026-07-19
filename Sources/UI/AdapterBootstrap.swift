import Adapter

public enum AdapterBootstrap {
    public static func fromEnvironment() -> AdapterHandling? {
        guard let config = AdapterEnvironment.configuration() else { return nil }
        return SocketAdapter(configuration: config)
    }
}
