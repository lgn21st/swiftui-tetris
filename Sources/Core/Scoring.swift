public enum Scoring {
    public static let classicLineScores: [Int] = [40, 100, 300, 1200]

    public static func classicScore(linesCleared: Int, level: Int) -> Int {
        guard linesCleared >= 1 && linesCleared <= 4 else { return 0 }
        let base = classicLineScores[linesCleared - 1]
        return base * (level + 1)
    }

    public static func modernScore(linesCleared: Int, level: Int, table: [Int]) -> Int {
        guard linesCleared >= 0 && linesCleared < table.count else { return 0 }
        return table[linesCleared] * (level + 1)
    }
}
