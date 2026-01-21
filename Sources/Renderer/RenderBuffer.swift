import Core

public final class RenderBuffer {
    public let width: Int
    public let height: Int
    public private(set) var cells: [CellRender]
    private var previousCells: [CellRender]

    public init(width: Int = Board.width, height: Int = Board.height) {
        self.width = width
        self.height = height
        var initial: [CellRender] = []
        initial.reserveCapacity(width * height)
        for y in 0..<height {
            for x in 0..<width {
                initial.append(CellRender(
                    x: x,
                    y: y,
                    kind: nil,
                    isGhost: false,
                    isActive: false,
                    isFlash: false
                ))
            }
        }
        self.cells = initial
        self.previousCells = initial
    }

    public func update(from state: RenderState) -> [Int] {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                cells[index].kind = state.board[y][x]
                cells[index].isGhost = false
                cells[index].isActive = false
                cells[index].isFlash = false
            }
        }

        for (x, y) in state.flashBlocks {
            guard x >= 0, y >= 0, x < width, y < height else { continue }
            cells[y * width + x].isFlash = true
        }

        for (x, y) in state.activeBlocks {
            guard x >= 0, y >= 0, x < width, y < height else { continue }
            let index = y * width + x
            cells[index].isActive = true
            if cells[index].kind == nil {
                cells[index].kind = state.activeKind
            }
        }

        for (x, y) in state.ghostBlocks {
            guard x >= 0, y >= 0, x < width, y < height else { continue }
            let index = y * width + x
            if cells[index].isActive { continue }
            cells[index].isGhost = true
            if cells[index].kind == nil {
                cells[index].kind = state.ghostKind
            }
        }

        var changed: [Int] = []
        changed.reserveCapacity(width * height / 4)
        for index in cells.indices {
            if cells[index] != previousCells[index] {
                changed.append(index)
                previousCells[index] = cells[index]
            }
        }
        return changed
    }
}
