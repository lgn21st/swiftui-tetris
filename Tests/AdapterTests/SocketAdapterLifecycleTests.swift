import Testing
@testable import Adapter

@Suite struct SocketAdapterLifecycleTests {
    @Test func explicitStartReportsBindFailure() throws {
        let first = SocketAdapter(
            configuration: .init(transport: .tcp(host: "127.0.0.1", port: 0)),
            startsImmediately: false
        )
        defer { first.stop() }
        try first.startOrThrow()
        let port = try #require(first.boundPort)
        let second = SocketAdapter(
            configuration: .init(transport: .tcp(host: "127.0.0.1", port: port)),
            startsImmediately: false
        )
        defer { second.stop() }

        #expect(throws: SocketTransportError.self) {
            try second.startOrThrow()
        }
    }
}
