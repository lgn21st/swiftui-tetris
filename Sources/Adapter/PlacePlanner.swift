import Core

struct PlacePlanner {
    static func plan(
        snapshot: GameStateSnapshot,
        targetX: Int,
        targetRotation: Rotation,
        maxDepth: Int = 40
    ) -> [GameAction]? {
        let start = PlanState(x: snapshot.active.x, y: snapshot.active.y, rotation: snapshot.active.rotation)
        let board = snapshot.boardCells
        let kind = snapshot.active.kind

        if !canPlace(kind: kind, state: start, board: board) {
            return nil
        }

        var queue: [(PlanState, [GameAction])] = [(start, [])]
        var index = 0
        var visited: Set<PlanState> = [start]

        while index < queue.count {
            let (state, actions) = queue[index]
            index += 1

            if state.x == targetX && state.rotation == targetRotation {
                return actions
            }
            if actions.count >= maxDepth { continue }

            for action in PlanAction.allCases {
                if let next = apply(action: action, kind: kind, state: state, board: board) {
                    if visited.insert(next).inserted {
                        queue.append((next, actions + [action.gameAction]))
                    }
                }
            }
        }

        return nil
    }

    private static func apply(
        action: PlanAction,
        kind: TetrominoType,
        state: PlanState,
        board: [[Cell]]
    ) -> PlanState? {
        switch action {
        case .moveLeft:
            let next = PlanState(x: state.x - 1, y: state.y, rotation: state.rotation)
            return canPlace(kind: kind, state: next, board: board) ? next : nil
        case .moveRight:
            let next = PlanState(x: state.x + 1, y: state.y, rotation: state.rotation)
            return canPlace(kind: kind, state: next, board: board) ? next : nil
        case .softDrop:
            let next = PlanState(x: state.x, y: state.y + 1, rotation: state.rotation)
            return canPlace(kind: kind, state: next, board: board) ? next : nil
        case .rotateCw:
            return rotate(kind: kind, from: state, clockwise: true, board: board)
        case .rotateCcw:
            return rotate(kind: kind, from: state, clockwise: false, board: board)
        }
    }

    private static func rotate(
        kind: TetrominoType,
        from state: PlanState,
        clockwise: Bool,
        board: [[Cell]]
    ) -> PlanState? {
        let nextRotation = clockwise ? state.rotation.cw() : state.rotation.ccw()
        let kicks = srsKicks(kind: kind, from: state.rotation, to: nextRotation)
        for (dx, dy) in kicks {
            let next = PlanState(x: state.x + dx, y: state.y + dy, rotation: nextRotation)
            if canPlace(kind: kind, state: next, board: board) {
                return next
            }
        }
        return nil
    }

    private static func canPlace(kind: TetrominoType, state: PlanState, board: [[Cell]]) -> Bool {
        let piece = Tetromino(kind: kind, x: state.x, y: state.y)
        let blocks = piece.blocks(rotation: state.rotation)
        for (dx, dy) in blocks {
            let nx = state.x + dx
            let ny = state.y + dy
            if nx < 0 || nx >= Board.width || ny < 0 || ny >= Board.height {
                return false
            }
            if board[ny][nx].filled {
                return false
            }
        }
        return true
    }
}

private struct PlanState: Hashable {
    let x: Int
    let y: Int
    let rotation: Rotation
}

private enum PlanAction: CaseIterable {
    case moveLeft
    case moveRight
    case softDrop
    case rotateCw
    case rotateCcw

    var gameAction: GameAction {
        switch self {
        case .moveLeft: return .moveLeft
        case .moveRight: return .moveRight
        case .softDrop: return .softDrop
        case .rotateCw: return .rotateCw
        case .rotateCcw: return .rotateCcw
        }
    }
}
