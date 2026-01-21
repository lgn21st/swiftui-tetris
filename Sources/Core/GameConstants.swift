public enum GameConstants {
    // Timing / rules
    public static let tickMs: Int = 16
    public static let softDropMultiplier: Int = 10
    public static let lockDelayMs: Int = 450
    public static let lockResetLimit: Int = 15
    public static let baseDropMs: Int = 1000
    public static let softDropGraceMs: Int = 150

    // Drop table + clamping
    public static let dropTable: [Int] = [1000, 800, 650, 500, 400, 320, 250, 200, 160]
    public static let dropTableFallbackMs: Int = 120
    public static let minimumDropMs: Int = 100

    // Input defaults
    public static let defaultDasMs: Int = 150
    public static let defaultArrMs: Int = 50

    // Visual timing
    public static let landingFlashDurationMs: Int = 120
    public static let lineClearPauseMs: Int = 180
}
