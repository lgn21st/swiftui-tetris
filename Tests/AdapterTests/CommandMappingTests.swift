import Testing
import Core
@testable import Adapter

@Suite struct CommandMappingTests {
    @Test func testMapsActionCommandToGameActions() throws {
        let command = TetrisAICommand.action(actions: [.rotateCw, .moveLeft, .hardDrop])
        let actions = try CommandMapper.map(command: command, snapshot: nil)

        #expect(actions == [.rotateCw, .moveLeft, .hardDrop])
    }

    @Test func testMapsPlaceCommandToActions() throws {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.active.rotation = .north
        let snapshot = state.snapshot()
        let command = TetrisAICommand.place(x: 5, rotation: .east, useHold: false)

        let actions = try CommandMapper.map(command: command, snapshot: snapshot)

        #expect(actions.last == .hardDrop)
        #expect(apply(actions: Array(actions.dropLast()), to: snapshot, targetX: 5, targetRotation: .east))
    }

    @Test func testMapsPlaceCommandWithHold() throws {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        state.hold = .z
        state.canHold = true
        let snapshot = state.snapshot()
        let command = TetrisAICommand.place(x: 3, rotation: .north, useHold: true)

        let actions = try CommandMapper.map(command: command, snapshot: snapshot)

        #expect(actions.first == .hold)
        #expect(actions.last == .hardDrop)
    }

    @Test func testPlacePlanUsesKickNearWall() throws {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 0, y: 0)
        state.active.rotation = .north
        let snapshot = state.snapshot()
        let command = TetrisAICommand.place(x: 1, rotation: .west, useHold: false)

        let actions = try CommandMapper.map(command: command, snapshot: snapshot)

        #expect(actions.last == .hardDrop)
        #expect(apply(actions: Array(actions.dropLast()), to: snapshot, targetX: 1, targetRotation: .west))
    }

    @Test func testPlaceCommandFailsWhenXOutOfBounds() {
        let state = GameState(config: GameConfig(), seed: 1)
        let snapshot = state.snapshot()
        let command = TetrisAICommand.place(x: 99, rotation: .north, useHold: false)

        let error = #expect(throws: (any Error).self) {
            try CommandMapper.map(command: command, snapshot: snapshot)
        }
        if let error {
            #expect(error as? CommandMappingError == .invalidPlace)
        }
    }

    @Test func testPlaceCommandFailsWhenBlockedAtSpawn() {
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

        let error = #expect(throws: (any Error).self) {
            try CommandMapper.map(command: command, snapshot: snapshot)
        }
        if let error {
            #expect(error as? CommandMappingError == .invalidPlace)
        }
    }

    @Test func testPlacePlannerHonorsDepthAndReturnsMinimumLengthReachablePlan() {
        var state = GameState(config: GameConfig(), seed: 1)
        state.active = Tetromino(kind: .t, x: 3, y: 0)
        let snapshot = state.snapshot()

        #expect(PlacePlanner.plan(snapshot: snapshot, targetX: 5, targetRotation: .east, maxDepth: 2) == nil)
        let plan = PlacePlanner.plan(snapshot: snapshot, targetX: 5, targetRotation: .east, maxDepth: 3)
        #expect(plan?.count == 3)
    }

    private func apply(
        actions: [GameAction],
        to snapshot: GameStateSnapshot,
        targetX: Int,
        targetRotation: TetrisAIRotation
    ) -> Bool {
        var state = GameState(config: snapshot.config, seed: 1)
        state.board.cells = snapshot.boardCells
        state.active = snapshot.active
        state.hold = snapshot.hold
        state.canHold = snapshot.canHold
        state.nextQueue = snapshot.nextQueue
        for action in actions {
            state.apply(action: action)
        }
        return state.active.x == targetX && state.active.rotation == targetRotation.toRotation()
    }
}
