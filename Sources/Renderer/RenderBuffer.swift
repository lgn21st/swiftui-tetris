import Core

public final class RenderBuffer {
    public let width: Int
    public let height: Int
    public private(set) var cells: [CellRender]
    public private(set) var flashIndices: [Int]
    public private(set) var lineClearIndices: [Int]
    public private(set) var changedIndices: [Int]
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
                    isFlash: false,
                    isLineClear: false
                ))
            }
        }
        self.cells = initial
        self.flashIndices = []
        self.lineClearIndices = []
        self.changedIndices = []
        self.previousCells = initial
    }

    public func update(from state: RenderState) {
        flashIndices.removeAll(keepingCapacity: true)
        lineClearIndices.removeAll(keepingCapacity: true)
        changedIndices.removeAll(keepingCapacity: true)
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                cells[index].kind = state.board[y][x]
                cells[index].isGhost = false
                cells[index].isActive = false
                cells[index].isFlash = false
                cells[index].isLineClear = false
            }
        }

        for (x, y) in state.flashBlocks {
            guard x >= 0, y >= 0, x < width, y < height else { continue }
            let index = y * width + x
            cells[index].isFlash = true
            flashIndices.append(index)
        }

        for row in state.lineClearRows {
            guard row >= 0, row < height else { continue }
            for x in 0..<width {
                let index = row * width + x
                cells[index].isLineClear = true
                lineClearIndices.append(index)
            }
        }

        for (x, y) in state.activeBlocks {
            guard x >= 0, y >= 0, x < width, y < height else { continue }
            let index = y * width + x
            cells[index].isActive = true
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

        for index in cells.indices {
            if cells[index] != previousCells[index] {
                changedIndices.append(index)
                previousCells[index] = cells[index]
            }
        }
    }
}
