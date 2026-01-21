import XCTest
import SpriteKit
@testable import Renderer
@testable import Core

final class TextureCacheTests: XCTestCase {
    func testTextureCacheReusesPieceTextures() {
        let cache = TextureCache(cellSize: 24)

        let first = cache.texture(for: .piece(kind: .i, ghost: false))
        let second = cache.texture(for: .piece(kind: .i, ghost: false))

        XCTAssertTrue(first === second)
    }

    func testTextureCacheSeparatesGhostAndSolidTextures() {
        let cache = TextureCache(cellSize: 24)

        let solid = cache.texture(for: .piece(kind: .t, ghost: false))
        let ghost = cache.texture(for: .piece(kind: .t, ghost: true))

        XCTAssertFalse(solid === ghost)
    }

    func testTextureCacheReusesFlashTexture() {
        let cache = TextureCache(cellSize: 24)

        let first = cache.texture(for: .flash)
        let second = cache.texture(for: .flash)

        XCTAssertTrue(first === second)
    }
}
