import Core
import Runtime

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

    public func setLeftHeld(_ held: Bool) -> GameAction? {
        leftHeld = held
        return syncMovement()
    }

    public func setRightHeld(_ held: Bool) -> GameAction? {
        rightHeld = held
        return syncMovement()
    }

    public func setDownHeld(_ held: Bool) -> GameAction? {
        downHeld = held
        if downHeld != downRepeat.isHeld() {
            if downHeld {
                if downRepeat.press() {
                    return .softDrop
                }
            } else {
                downRepeat.release()
            }
        }
        return nil
    }

    public func produceActions(elapsedMs: Int, canAccept: Bool, emit: (GameAction) -> Void) {
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
                for _ in 0..<count { emit(.moveLeft) }
            case .right:
                count = rightRepeat.tick(elapsedMs: elapsedMs, config: repeatConfig)
                for _ in 0..<count { emit(.moveRight) }
            }
        }

        if downRepeat.isHeld() {
            let count = downRepeat.tick(elapsedMs: elapsedMs, config: softDropRepeatConfig)
            for _ in 0..<count { emit(.softDrop) }
        }
    }

    public func updateConfig(repeatConfig: RepeatConfig, softDropRepeatConfig: RepeatConfig) {
        self.repeatConfig = repeatConfig
        self.softDropRepeatConfig = softDropRepeatConfig
        leftRepeat.syncHeld(leftHeld)
        rightRepeat.syncHeld(rightHeld)
        downRepeat.syncHeld(downHeld)
        lastDir = leftHeld ? .left : (rightHeld ? .right : nil)
    }

    public func releaseMovementHolds() {
        leftHeld = false
        rightHeld = false
        downHeld = false
        leftRepeat.release()
        rightRepeat.release()
        downRepeat.release()
        lastDir = nil
    }

    public func reset() {
        releaseMovementHolds()
    }

    private func syncMovement() -> GameAction? {
        var action: GameAction?
        if leftHeld != leftRepeat.isHeld() {
            if leftHeld {
                if leftRepeat.press() {
                    action = .moveLeft
                }
            } else {
                leftRepeat.release()
            }
        }

        if rightHeld != rightRepeat.isHeld() {
            if rightHeld {
                if rightRepeat.press() {
                    action = .moveRight
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
        return action
    }
}

extension InputEngine: GameRuntimeInput {}
