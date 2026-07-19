import Foundation
import Testing
@testable import Adapter

@Suite struct AdapterSessionRegistryTests {
    @Test func assignsOneControllerAndFiltersObservationTargets() {
        var registry = AdapterSessionRegistry()
        let first = UUID()
        let second = UUID()

        let controller = registry.register(first, requestedRole: .auto, streamsObservations: true)
        let observer = registry.register(second, requestedRole: .observer, streamsObservations: false)

        #expect(controller.role == .controller)
        #expect(controller.controllerClientId == controller.clientId)
        #expect(observer.role == .observer)
        #expect(observer.controllerClientId == controller.clientId)
        #expect(registry.observationTargets == [first])
    }

    @Test func acceptsOnlyStrictlyIncreasingSequenceNumbers() {
        var registry = AdapterSessionRegistry()
        let connection = UUID()
        _ = registry.register(connection, requestedRole: .auto, streamsObservations: false)

        let first = registry.accept(sequence: 2, from: connection)
        let duplicate = registry.accept(sequence: 2, from: connection)
        let stale = registry.accept(sequence: 1, from: connection)
        let later = registry.accept(sequence: 9, from: connection)

        #expect(first)
        #expect(!duplicate)
        #expect(!stale)
        #expect(later)
    }

    @Test func releasedControlCanBeClaimedByAnObserver() {
        var registry = AdapterSessionRegistry()
        let first = UUID()
        let observer = UUID()
        _ = registry.register(first, requestedRole: .controller, streamsObservations: false)
        _ = registry.register(observer, requestedRole: .observer, streamsObservations: false)

        let released = registry.release(first)
        let claimed = registry.claim(observer)

        #expect(released)
        #expect(claimed)
        #expect(registry.isController(observer))
    }

    @Test func disconnectPromotesOldestEligibleObserver() {
        var registry = AdapterSessionRegistry()
        let controller = UUID()
        let ineligible = UUID()
        let eligible = UUID()
        _ = registry.register(controller, requestedRole: .controller, streamsObservations: false)
        _ = registry.register(ineligible, requestedRole: .observer, streamsObservations: false)
        _ = registry.register(eligible, requestedRole: .auto, streamsObservations: false)

        registry.disconnect(controller)

        #expect(!registry.isController(ineligible))
        #expect(registry.isController(eligible))
    }
}
