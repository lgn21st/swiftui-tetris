import Testing
@testable import UI
@testable import Core

@Suite struct PreviewGridStateTests {
    @Test func testPreviewGridStateUsesMask() {
        let state = PreviewGridState.from(kind: .o)
        #expect(state.filledCount() == 4)
    }

    @Test func testPreviewGridStateNilIsEmpty() {
        let state = PreviewGridState.from(kind: nil)
        #expect(state.filledCount() == 0)
    }
}
