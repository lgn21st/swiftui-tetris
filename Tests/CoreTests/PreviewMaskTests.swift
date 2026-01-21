import XCTest
@testable import Core

final class PreviewMaskTests: XCTestCase {
    func testPreviewMaskHasBlocksForPiece() {
        let cache = PreviewMaskCache()
        let mask = cache.mask(for: .i)
        let filled = mask.flatMap { $0 }.filter { $0 }
        XCTAssertFalse(filled.isEmpty)
    }

    func testPreviewMaskEmptyForNil() {
        let cache = PreviewMaskCache()
        let mask = cache.mask(for: nil)
        let filled = mask.flatMap { $0 }.filter { $0 }
        XCTAssertTrue(filled.isEmpty)
    }
}
