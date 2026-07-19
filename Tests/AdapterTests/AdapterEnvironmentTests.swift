import Testing
@testable import Adapter

@Suite struct AdapterEnvironmentTests {
    @Test func defaultsToThePortableTcpEndpointAndLocalResourcePolicy() {
        let config = AdapterEnvironment.configuration(from: [:])

        #expect(config?.transport == .tcp(host: "127.0.0.1", port: 7777))
        #expect(config?.idleTimeoutMs == 2000)
        #expect(config?.maxPendingCommands == 64)
        #expect(config?.maxOutboundBytes == 262_144)
        #expect(config?.backpressureRetryAfterMs == 50)
        #expect(config?.observationIntervalMs == nil)
        #expect(config?.logPath == "auto")
    }

    @Test func parsesProjectLocalResourceOverrides() {
        let config = AdapterEnvironment.configuration(from: [
            "TETRIS_AI_HOST": "0.0.0.0",
            "TETRIS_AI_PORT": "8888",
            "TETRIS_AI_IDLE_TIMEOUT_MS": "0",
            "TETRIS_AI_MAX_PENDING": "12",
            "TETRIS_AI_MAX_OUTBOUND_BYTES": "131072",
            "TETRIS_AI_BACKPRESSURE_RETRY_MS": "25",
            "TETRIS_AI_OBSERVATION_MS": "50",
            "TETRIS_AI_LOG_PATH": "/tmp/adapter.log",
        ])

        #expect(config?.transport == .tcp(host: "0.0.0.0", port: 8888))
        #expect(config?.idleTimeoutMs == nil)
        #expect(config?.maxPendingCommands == 12)
        #expect(config?.maxOutboundBytes == 131_072)
        #expect(config?.backpressureRetryAfterMs == 25)
        #expect(config?.observationIntervalMs == 50)
        #expect(config?.logPath == "/tmp/adapter.log")
    }

    @Test(arguments: ["1", "true", "TRUE"])
    func disablesAdapter(_ value: String) {
        #expect(AdapterEnvironment.configuration(from: ["TETRIS_AI_DISABLED": value]) == nil)
    }
}
