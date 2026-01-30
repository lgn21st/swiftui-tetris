import XCTest
import Core
@testable import Adapter

final class CommandMappingTests: XCTestCase {
    func testMapsActionCommandToGameActions() throws {
        let command = TetrisAICommand.action(actions: [.rotateCw, .moveLeft, .hardDrop])
        let actions = try CommandMapper.map(command: command, snapshot: nil)

        XCTAssertEqual(actions, [.rotateCw, .moveLeft, .hardDrop])
    }

    func testMapsPlaceCommandToActions() throws {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.active.rotation = .north
        let snapshot = state.snapshot()
        let command = TetrisAICommand.place(x: 5, rotation: .east, useHold: false)

        let actions = try CommandMapper.map(command: command, snapshot: snapshot)

        XCTAssertEqual(actions, [.rotateCw, .moveRight, .moveRight, .hardDrop])
    }

    func testMapsPlaceCommandWithHold() throws {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.hold = .z
        state.canHold = true
        let snapshot = state.snapshot()
        let command = TetrisAICommand.place(x: 3, rotation: .north, useHold: true)

        let actions = try CommandMapper.map(command: command, snapshot: snapshot)

        XCTAssertEqual(actions, [.hold, .hardDrop])
    }

    func testPlaceCommandFailsWhenXOutOfBounds() {
        let state = GameState(config: GameConfig(), seed: 1)
        let snapshot = state.snapshot()
        let command = TetrisAICommand.place(x: 99, rotation: .north, useHold: false)

        XCTAssertThrowsError(try CommandMapper.map(command: command, snapshot: snapshot)) { error in
            XCTAssertEqual(error as? CommandMappingError, .invalidPlace)
        }
    }

    func testPlaceCommandFailsWhenBlockedAtSpawn() {
        var state = GameState(config: GameConfig(), seed: 1)
        let spawn = spawnPosition()
        for (dx, dy) in state.active.blocks(rotation: state.active.rotation) {
            let x = spawn.x + dx
            let y = spawn.y + dy
            if x >= 0 && x < Board.width && y >= 0 && y < Board.height {
                state.board.cells[y][x].filled = true
            }
        }
        let snapshot = state.snapshot()
        let command = TetrisAICommand.place(x: spawn.x, rotation: .north, useHold: false)

        XCTAssertThrowsError(try CommandMapper.map(command: command, snapshot: snapshot)) { error in
            XCTAssertEqual(error as? CommandMappingError, .invalidPlace)
        }
    }
}
