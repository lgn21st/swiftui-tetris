import Testing
@testable import Core

@Suite struct PiecesTests {
    @Test func testEveryTetrominoRotationHasFourStableUniqueBlocks() {
        for kind in TetrominoType.allCases {
            let piece = Tetromino(kind: kind, x: 0, y: 0)
            for rotation in Rotation.allCases {
                let first = piece.blocks(rotation: rotation)
                let second = piece.blocks(rotation: rotation)
                #expect(first.count == 4)
                #expect(Set(first.map { "\($0.0),\($0.1)" }).count == 4)
                #expect(first.map { [$0.0, $0.1] } == second.map { [$0.0, $0.1] })
            }
        }
    }

    @Test func testSpawnPosition() {
        #expect(spawnPosition().x == 3)
        #expect(spawnPosition().y == 0)
    }

    @Test func testTetrominoBlocksCount() {
        let types: [TetrominoType] = [.i, .o, .t, .s, .z, .j, .l]
        for type in types {
            let piece = Tetromino(kind: type, x: 0, y: 0)
            let blocks = piece.blocks(rotation: .north)
            #expect(blocks.count == 4)
        }
    }

    @Test func testIShapeNorth() {
        let piece = Tetromino(kind: .i, x: 0, y: 0)
        assertBlocksEqual(piece.blocks(rotation: .north), [
            (0, 1), (1, 1), (2, 1), (3, 1)
        ])
    }

    @Test func testOShapeAnyRotation() {
        let piece = Tetromino(kind: .o, x: 0, y: 0)
        let expected = [(1, 0), (2, 0), (1, 1), (2, 1)]
        assertBlocksEqual(piece.blocks(rotation: .north), expected)
        assertBlocksEqual(piece.blocks(rotation: .east), expected)
        assertBlocksEqual(piece.blocks(rotation: .south), expected)
        assertBlocksEqual(piece.blocks(rotation: .west), expected)
    }

    private func assertBlocksEqual(_ actual: [(Int, Int)], _ expected: [(Int, Int)]) {
        #expect(Set(actual.map { "\($0.0),\($0.1)" }) == Set(expected.map { "\($0.0),\($0.1)" }))
    }
}
