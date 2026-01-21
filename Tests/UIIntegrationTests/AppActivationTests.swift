import XCTest
import AppKit
@testable import UI

final class AppActivationTests: XCTestCase {
    private final class MockApp: ApplicationActivating {
        var policy: NSApplication.ActivationPolicy?
        var activatedFlag: Bool?

        func setActivationPolicy(_ policy: NSApplication.ActivationPolicy) -> Bool {
            self.policy = policy
            return true
        }

        func activate(ignoringOtherApps flag: Bool) {
            activatedFlag = flag
        }
    }

    func testAppActivationConfiguresPolicyAndActivation() {
        let mock = MockApp()
        AppActivation.configure(app: mock)
        XCTAssertEqual(mock.policy, .regular)
        XCTAssertEqual(mock.activatedFlag, true)
    }
}
