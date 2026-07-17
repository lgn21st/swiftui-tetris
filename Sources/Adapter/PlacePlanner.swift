import Core

struct PlacePlanner {
    private struct CostWeights {
        let move: Int = 1
        let rotate: Int = 3
        let softDrop: Int = 4
    }

    static func plan(
        snapshot: GameStateSnapshot,
        targetX: Int,
        targetRotation: Rotation,
        maxDepth: Int = 40
    ) -> [GameAction]? {
        let start = PlanState(x: snapshot.active.x, y: snapshot.active.y, rotation: snapshot.active.rotation)
        let board = snapshot.boardCells
        let kind = snapshot.active.kind
        let weights = CostWeights()

        if !canPlace(kind: kind, state: start, board: board) {
            return nil
        }

        var queue = MinHeap()
        queue.push(QueueEntry(state: start, cost: 0, depth: 0, order: 0))
        var bestCost: [PlanState: Int] = [start: 0]
        var predecessors: [PlanState: Predecessor] = [:]
        var nextOrder = 1

        while let entry = queue.pop() {
            let state = entry.state
            let cost = entry.cost
            guard bestCost[state] == cost else { continue }

            if state.x == targetX && state.rotation == targetRotation {
                return reconstructPlan(to: state, from: start, predecessors: predecessors)
            }
            if entry.depth >= maxDepth { continue }

            for action in PlanAction.allCases {
                if let next = apply(action: action, kind: kind, state: state, board: board) {
                    let stepCost: Int
                    switch action {
                    case .moveLeft, .moveRight:
                        stepCost = weights.move
                    case .rotateCw, .rotateCcw:
                        stepCost = weights.rotate
                    case .softDrop:
                        stepCost = weights.softDrop
                    }
                    let nextCost = cost + stepCost
                    let known = bestCost[next] ?? Int.max
                    if nextCost < known {
                        bestCost[next] = nextCost
                        predecessors[next] = Predecessor(state: state, action: action.gameAction)
                        queue.push(QueueEntry(
                            state: next,
                            cost: nextCost,
                            depth: entry.depth + 1,
                            order: nextOrder
                        ))
                        nextOrder += 1
                    }
                }
            }
        }

        return nil
    }

    private static func reconstructPlan(
        to target: PlanState,
        from start: PlanState,
        predecessors: [PlanState: Predecessor]
    ) -> [GameAction] {
        var actions: [GameAction] = []
        var current = target
        while current != start, let predecessor = predecessors[current] {
            actions.append(predecessor.action)
            current = predecessor.state
        }
        return actions.reversed()
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

private struct Predecessor {
    let state: PlanState
    let action: GameAction
}

private struct QueueEntry {
    let state: PlanState
    let cost: Int
    let depth: Int
    let order: Int

    func precedes(_ other: QueueEntry) -> Bool {
        cost < other.cost || (cost == other.cost && order < other.order)
    }
}

private struct MinHeap {
    private var storage: [QueueEntry] = []

    mutating func push(_ entry: QueueEntry) {
        storage.append(entry)
        var child = storage.count - 1
        while child > 0 {
            let parent = (child - 1) / 2
            guard storage[child].precedes(storage[parent]) else { break }
            storage.swapAt(child, parent)
            child = parent
        }
    }

    mutating func pop() -> QueueEntry? {
        guard !storage.isEmpty else { return nil }
        if storage.count == 1 { return storage.removeLast() }

        let result = storage[0]
        storage[0] = storage.removeLast()
        var parent = 0
        while true {
            let left = parent * 2 + 1
            guard left < storage.count else { break }
            let right = left + 1
            let next = right < storage.count && storage[right].precedes(storage[left]) ? right : left
            guard storage[next].precedes(storage[parent]) else { break }
            storage.swapAt(parent, next)
            parent = next
        }
        return result
    }
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
