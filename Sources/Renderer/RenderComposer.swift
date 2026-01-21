import Core

public struct CellRender: Equatable {
    public var x: Int
    public var y: Int
    public var kind: TetrominoType?
    public var isGhost: Bool
    public var isActive: Bool
    public var isFlash: Bool
    public var isTrail: Bool
    public var isLineClear: Bool
}

@available(*, deprecated, message: "Use RenderBuffer for in-place updates to avoid per-frame allocations.")
public enum RenderComposer {
    public static func compose(from state: RenderState) -> [CellRender] {
        var cells: [CellRender] = []
        cells.reserveCapacity(state.board.count * (state.board.first?.count ?? 0))
        for y in 0..<state.board.count {
            for x in 0..<state.board[y].count {
                let kind = state.board[y][x]
                cells.append(CellRender(
                    x: x,
                    y: y,
                    kind: kind,
                    isGhost: false,
                    isActive: false,
                    isFlash: false,
                    isTrail: false,
                    isLineClear: false
                ))
            }
        }

        let ghostSet = Set(state.ghostBlocks.map { "\($0.0),\($0.1)" })
        let activeSet = Set(state.activeBlocks.map { "\($0.0),\($0.1)" })
        let flashSet = Set(state.flashBlocks.map { "\($0.0),\($0.1)" })
        let trailSet = Set(state.softDropTrailBlocks.map { "\($0.0),\($0.1)" })
        let lineClearRows = Set(state.lineClearRows)

        for index in cells.indices {
            let key = "\(cells[index].x),\(cells[index].y)"
            if flashSet.contains(key) {
                cells[index].isFlash = true
            }
            if lineClearRows.contains(cells[index].y) {
                cells[index].isLineClear = true
            }
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
            } else if trailSet.contains(key) {
                cells[index].isTrail = true
                if cells[index].kind == nil {
                    cells[index].kind = state.softDropTrailKind
                }
            }
        }

        return cells
    }
}
