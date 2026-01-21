import XCTest
@testable import UI
@testable import Core

final class PreviewGridStateTests: XCTestCase {
    func testPreviewGridStateUsesMask() {
        let state = PreviewGridState.from(kind: .o)
        XCTAssertEqual(state.filledCount(), 4)
    }

    func testPreviewGridStateNilIsEmpty() {
        let state = PreviewGridState.from(kind: nil)
        XCTAssertEqual(state.filledCount(), 0)
    }
}
