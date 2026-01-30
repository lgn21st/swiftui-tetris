import Core

public protocol AdapterHandling {
    func poll(elapsedMs: Int, state: inout GameState)
    func emit(snapshot: GameStateSnapshot)
}
