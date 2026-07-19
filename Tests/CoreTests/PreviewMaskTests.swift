import Testing
@testable import Core

@Suite struct PreviewMaskTests {
    @Test func testPreviewMaskHasBlocksForPiece() {
        let cache = PreviewMaskCache()
        let mask = cache.mask(for: .i)
        let filled = mask.flatMap { $0 }.filter { $0 }
        #expect(!filled.isEmpty)
    }

    @Test func testPreviewMaskEmptyForNil() {
        let cache = PreviewMaskCache()
        let mask = cache.mask(for: nil)
        let filled = mask.flatMap { $0 }.filter { $0 }
        #expect(filled.isEmpty)
    }
}
