import XCTest
@testable import Core

final class PiecesTests: XCTestCase {
    func testSpawnPosition() {
        XCTAssertEqual(spawnPosition().x, 3)
        XCTAssertEqual(spawnPosition().y, 0)
    }

    func testTetrominoBlocksCount() {
        let types: [TetrominoType] = [.i, .o, .t, .s, .z, .j, .l]
        for type in types {
            let piece = Tetromino(kind: type, x: 0, y: 0)
            let blocks = piece.blocks(rotation: .north)
            XCTAssertEqual(blocks.count, 4)
        }
    }

    func testIShapeNorth() {
        let piece = Tetromino(kind: .i, x: 0, y: 0)
        assertBlocksEqual(piece.blocks(rotation: .north), [
            (0, 1), (1, 1), (2, 1), (3, 1)
        ])
    }

    func testOShapeAnyRotation() {
        let piece = Tetromino(kind: .o, x: 0, y: 0)
        let expected = [(1, 0), (2, 0), (1, 1), (2, 1)]
        assertBlocksEqual(piece.blocks(rotation: .north), expected)
        assertBlocksEqual(piece.blocks(rotation: .east), expected)
        assertBlocksEqual(piece.blocks(rotation: .south), expected)
        assertBlocksEqual(piece.blocks(rotation: .west), expected)
    }

    private func assertBlocksEqual(_ actual: [(Int, Int)], _ expected: [(Int, Int)], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(Set(actual.map { "\($0.0),\($0.1)" }), Set(expected.map { "\($0.0),\($0.1)" }), file: file, line: line)
    }
}
