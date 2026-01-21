import XCTest
@testable import Renderer
@testable import Core

final class TextureCacheTests: XCTestCase {
    func testTextureCacheReusesTexturesPerKey() {
        let cache = TextureCache(cellSize: 10)
        let first = cache.texture(for: .piece(kind: .i, ghost: false, style: .normal))
        let second = cache.texture(for: .piece(kind: .i, ghost: false, style: .normal))
        XCTAssertTrue(first === second)
    }

    func testTextureCacheSeparatesStyles() {
        let cache = TextureCache(cellSize: 10)
        let normal = cache.texture(for: .piece(kind: .t, ghost: false, style: .normal))
        let highlight = cache.texture(for: .piece(kind: .t, ghost: false, style: .highlight))
        let trail = cache.texture(for: .piece(kind: .t, ghost: false, style: .trail))
        XCTAssertFalse(normal === highlight)
        XCTAssertFalse(normal === trail)
    }
}
