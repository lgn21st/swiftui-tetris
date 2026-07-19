import Testing
import AppKit
@testable import UI

@Suite struct AppActivationTests {
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

    @Test func testAppActivationConfiguresPolicyAndActivation() {
        let mock = MockApp()
        AppActivation.configure(app: mock)
        #expect(mock.policy == .regular)
        #expect(mock.activatedFlag == true)
    }
}
