import Core
import Renderer

public final class GameLoop {
    public var state: GameState

    public init(state: GameState = GameState(config: GameConfig(), seed: 1)) {
        self.state = state
    }

    public func apply(action: GameAction) {
        state.apply(action: action)
    }

    public func step(elapsedMs: Int, softDrop: Bool = false) -> RenderState {
        state.tick(elapsedMs: elapsedMs, softDrop: softDrop)
        return RenderMapper.map(snapshot: state.snapshot())
    }

    public func stepFrame(elapsedMs: Int) -> RenderState {
        step(elapsedMs: elapsedMs)
    }
}
