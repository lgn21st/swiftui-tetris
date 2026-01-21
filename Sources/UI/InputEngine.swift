import Core

public final class InputEngine {
    private enum AxisDirection {
        case left
        case right
    }

    private var repeatConfig: RepeatConfig
    private var softDropRepeatConfig: RepeatConfig
    private var leftRepeat: RepeatState
    private var rightRepeat: RepeatState
    private var downRepeat: RepeatState
    private var leftHeld: Bool
    private var rightHeld: Bool
    private var downHeld: Bool
    private var lastDir: AxisDirection?

    public init(
        repeatConfig: RepeatConfig = RepeatConfig(),
        softDropRepeatConfig: RepeatConfig = RepeatConfig(dasMs: 0, arrMs: 50)
    ) {
        self.repeatConfig = repeatConfig
        self.softDropRepeatConfig = softDropRepeatConfig
        self.leftRepeat = RepeatState()
        self.rightRepeat = RepeatState()
        self.downRepeat = RepeatState()
        self.leftHeld = false
        self.rightHeld = false
        self.downHeld = false
        self.lastDir = nil
    }

    public func apply(action: GameAction, to state: inout GameState) {
        state.apply(action: action)
    }

    public func setLeftHeld(_ held: Bool, state: inout GameState) {
        leftHeld = held
        syncMovement(state: &state)
    }

    public func setRightHeld(_ held: Bool, state: inout GameState) {
        rightHeld = held
        syncMovement(state: &state)
    }

    public func setDownHeld(_ held: Bool, state: inout GameState) {
        downHeld = held
        if downHeld != downRepeat.isHeld() {
            if downHeld {
                if downRepeat.press() {
                    state.apply(action: .softDrop)
                }
            } else {
                downRepeat.release()
            }
        }
    }

    public func tick(elapsedMs: Int, canAccept: Bool, state: inout GameState) {
        if !canAccept {
            leftRepeat.release()
            rightRepeat.release()
            downRepeat.release()
            lastDir = nil
            return
        }

        let direction: AxisDirection?
        switch (leftRepeat.isHeld(), rightRepeat.isHeld()) {
        case (true, false): direction = .left
        case (false, true): direction = .right
        case (true, true): direction = lastDir
        default: direction = nil
        }

        if let direction {
            let count: Int
            switch direction {
            case .left:
                count = leftRepeat.tick(elapsedMs: elapsedMs, config: repeatConfig)
                for _ in 0..<count { state.apply(action: .moveLeft) }
            case .right:
                count = rightRepeat.tick(elapsedMs: elapsedMs, config: repeatConfig)
                for _ in 0..<count { state.apply(action: .moveRight) }
            }
        }

        if downRepeat.isHeld() {
            let count = downRepeat.tick(elapsedMs: elapsedMs, config: softDropRepeatConfig)
            for _ in 0..<count { state.apply(action: .softDrop) }
        }
    }

    public func reset() {
        leftHeld = false
        rightHeld = false
        downHeld = false
        leftRepeat.release()
        rightRepeat.release()
        downRepeat.release()
        lastDir = nil
    }

    private func syncMovement(state: inout GameState) {
        if leftHeld != leftRepeat.isHeld() {
            if leftHeld {
                if leftRepeat.press() {
                    state.apply(action: .moveLeft)
                }
            } else {
                leftRepeat.release()
            }
        }

        if rightHeld != rightRepeat.isHeld() {
            if rightHeld {
                if rightRepeat.press() {
                    state.apply(action: .moveRight)
                }
            } else {
                rightRepeat.release()
            }
        }

        switch (leftHeld, rightHeld) {
        case (true, false): lastDir = .left
        case (false, true): lastDir = .right
        case (false, false): lastDir = nil
        default: break
        }
    }
}
