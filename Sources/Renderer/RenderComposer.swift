import Core

public struct CellRender: Equatable {
    public var x: Int
    public var y: Int
    public var kind: TetrominoType?
    public var isGhost: Bool
    public var isActive: Bool
}

public enum RenderComposer {
    public static func compose(from state: RenderState) -> [CellRender] {
        var cells: [CellRender] = []
        for y in 0..<state.board.count {
            for x in 0..<state.board[y].count {
                let kind = state.board[y][x]
                cells.append(CellRender(x: x, y: y, kind: kind, isGhost: false, isActive: false))
            }
        }

        let ghostSet = Set(state.ghostBlocks.map { "\($0.0),\($0.1)" })
        let activeSet = Set(state.activeBlocks.map { "\($0.0),\($0.1)" })

        for index in cells.indices {
            let key = "\(cells[index].x),\(cells[index].y)"
            if activeSet.contains(key) {
                cells[index].isActive = true
                if cells[index].kind == nil {
                    cells[index].kind = state.activeKind
                }
            } else if ghostSet.contains(key) {
                cells[index].isGhost = true
                if cells[index].kind == nil {
                    cells[index].kind = state.ghostKind
                }
            }
        }

        return cells
    }
}
