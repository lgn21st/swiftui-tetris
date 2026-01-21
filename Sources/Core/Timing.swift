public enum Timing {
    private static let dropTable: [Int] = [1000, 800, 650, 500, 400, 320, 250, 200, 160]

    public static func dropInterval(
        level: Int,
        baseDropMs: Int,
        softDrop: Bool,
        softDropMultiplier: Int
    ) -> Int {
        let tableValue = dropTable.indices.contains(level) ? dropTable[level] : 120
        var interval = min(tableValue, baseDropMs)
        interval = max(interval, 100)
        guard softDrop else { return interval }

        let multiplier = max(softDropMultiplier, 1)
        return max(interval / multiplier, 1)
    }
}
