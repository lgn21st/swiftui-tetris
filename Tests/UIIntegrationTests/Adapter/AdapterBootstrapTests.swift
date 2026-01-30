import XCTest
import Adapter
@testable import UI

final class AdapterBootstrapTests: XCTestCase {
    func testConfigurationDefaultsToUnixWhenEnvMissing() {
        let env: [String: String] = [:]

        let config = AdapterBootstrap.configuration(from: env)

        XCTAssertEqual(config?.transport, .unix(path: "/tmp/tetris-ai.sock"))
        XCTAssertEqual(config?.idleTimeoutMs, 2000)
        XCTAssertEqual(config?.maxPendingCommands, 64)
        XCTAssertNil(config?.observationIntervalMs)
        XCTAssertEqual(config?.logPath, "auto")
    }

    func testConfigurationDefaultsToUnixPathWithDefaults() {
        let env: [String: String] = [
            "TETRIS_AI_TRANSPORT": "unix"
        ]

        let config = AdapterBootstrap.configuration(from: env)

        XCTAssertEqual(config?.transport, .unix(path: "/tmp/tetris-ai.sock"))
        XCTAssertEqual(config?.idleTimeoutMs, 2000)
        XCTAssertEqual(config?.maxPendingCommands, 64)
        XCTAssertNil(config?.observationIntervalMs)
        XCTAssertEqual(config?.logPath, "auto")
    }

    func testConfigurationParsesOverridesForTcp() {
        let env: [String: String] = [
            "TETRIS_AI_TRANSPORT": "tcp",
            "TETRIS_AI_HOST": "0.0.0.0",
            "TETRIS_AI_PORT": "8888",
            "TETRIS_AI_IDLE_TIMEOUT_MS": "0",
            "TETRIS_AI_MAX_PENDING": "12",
            "TETRIS_AI_OBSERVATION_MS": "50",
            "TETRIS_AI_LOG_PATH": "/tmp/adapter.log"
        ]

        let config = AdapterBootstrap.configuration(from: env)

        XCTAssertEqual(config?.transport, .tcp(host: "0.0.0.0", port: 8888))
        XCTAssertNil(config?.idleTimeoutMs)
        XCTAssertEqual(config?.maxPendingCommands, 12)
        XCTAssertEqual(config?.observationIntervalMs, 50)
        XCTAssertEqual(config?.logPath, "/tmp/adapter.log")
    }

    func testConfigurationReturnsNilWhenDisabled() {
        let env: [String: String] = [
            "TETRIS_AI_DISABLED": "1"
        ]

        let config = AdapterBootstrap.configuration(from: env)

        XCTAssertNil(config)
    }
}
