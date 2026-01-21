import SwiftUI
import Core

public struct PreviewGridView: View {
    public let state: PreviewGridState
    public let cellSize: CGFloat

    public init(state: PreviewGridState, cellSize: CGFloat = LayoutConstants.previewCell) {
        self.state = state
        self.cellSize = cellSize
    }

    public var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<state.mask.count, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<state.mask[row].count, id: \.self) { col in
                        let filled = state.mask[row][col]
                        Rectangle()
                            .fill(filled ? TetrominoPalette.color(for: state.kind) : Color.clear)
                            .frame(width: cellSize, height: cellSize)
                            .overlay(
                                Rectangle().stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(4)
        .background(Color.black.opacity(ThemeConstants.previewOpacity))
        .cornerRadius(6)
    }
}
