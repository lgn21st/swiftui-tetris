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
}
