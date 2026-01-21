public enum Timing {
    public static func dropInterval(
        level: Int,
        baseDropMs: Int,
        softDrop: Bool,
        softDropMultiplier: Int
    ) -> Int {
        let tableValue = GameConstants.dropTable.indices.contains(level)
            ? GameConstants.dropTable[level]
            : GameConstants.dropTableFallbackMs
        var interval = min(tableValue, baseDropMs)
        interval = max(interval, GameConstants.minimumDropMs)
        guard softDrop else { return interval }

        let multiplier = max(softDropMultiplier, 1)
        return max(interval / multiplier, 1)
    }
}
