import Core

enum AdapterCommandExecutor {
    static func execute(
        _ command: TetrisAICommand,
        restartSeed: UInt32? = nil,
        state: inout GameState
    ) throws -> GameStateSnapshot {
        let actions = try CommandMapper.map(command: command, snapshot: state.snapshot())
        for action in actions {
            if action == .restart, let restartSeed {
                state.restart(seed: UInt64(restartSeed))
            } else {
                state.apply(action: action)
            }
        }
        return state.snapshot()
    }
}
