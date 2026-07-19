import Testing
import Adapter
@testable import UI

@Suite struct AdapterBootstrapTests {
    @Test func testConfigurationDefaultsToTcpWhenEnvMissing() {
        let env: [String: String] = [:]

        let config = AdapterBootstrap.configuration(from: env)

        #expect(config?.transport == .tcp(host: "127.0.0.1", port: 7777))
        #expect(config?.idleTimeoutMs == 2000)
        #expect(config?.maxPendingCommands == 64)
        #expect(config?.maxOutboundBytes == 262_144)
        #expect(config?.backpressureRetryAfterMs == 50)
        #expect(config?.observationIntervalMs == nil)
        #expect(config?.logPath == "auto")
    }

    @Test func testConfigurationParsesOverridesForTcp() {
        let env: [String: String] = [
            "TETRIS_AI_HOST": "0.0.0.0",
            "TETRIS_AI_PORT": "8888",
            "TETRIS_AI_IDLE_TIMEOUT_MS": "0",
            "TETRIS_AI_MAX_PENDING": "12",
            "TETRIS_AI_OBSERVATION_MS": "50",
            "TETRIS_AI_LOG_PATH": "/tmp/adapter.log"
        ]

        let config = AdapterBootstrap.configuration(from: env)

        #expect(config?.transport == .tcp(host: "0.0.0.0", port: 8888))
        #expect(config?.idleTimeoutMs == nil)
        #expect(config?.maxPendingCommands == 12)
        #expect(config?.observationIntervalMs == 50)
        #expect(config?.logPath == "/tmp/adapter.log")
    }

    @Test func testConfigurationReturnsNilWhenDisabled() {
        let env: [String: String] = [
            "TETRIS_AI_DISABLED": "1"
        ]

        let config = AdapterBootstrap.configuration(from: env)

        #expect(config == nil)
    }


    @Test func testConfigurationRecognizesTrueAsDisabledAndParsesResourceOverrides() {
        #expect(AdapterBootstrap.configuration(from: ["TETRIS_AI_DISABLED": "true"]) == nil)

        let config = AdapterBootstrap.configuration(from: [
            "TETRIS_AI_MAX_OUTBOUND_BYTES": "131072",
            "TETRIS_AI_BACKPRESSURE_RETRY_MS": "25",
        ])
        #expect(config?.maxOutboundBytes == 131_072)
        #expect(config?.backpressureRetryAfterMs == 25)
    }
}
