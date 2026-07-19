import Testing
@testable import Core

@Suite struct RotationTests {
    @Test func testRotationCwCycles() {
        #expect(Rotation.north.cw() == .east)
        #expect(Rotation.east.cw() == .south)
        #expect(Rotation.south.cw() == .west)
        #expect(Rotation.west.cw() == .north)
    }

    @Test func testRotationCcwCycles() {
        #expect(Rotation.north.ccw() == .west)
        #expect(Rotation.west.ccw() == .south)
        #expect(Rotation.south.ccw() == .east)
        #expect(Rotation.east.ccw() == .north)
    }
}
