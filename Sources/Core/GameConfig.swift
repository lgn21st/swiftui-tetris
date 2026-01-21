public struct GameConfig: Equatable {
    public var tickMs: Int
    public var softDropMultiplier: Int
    public var lockDelayMs: Int
    public var lockResetLimit: Int
    public var baseDropMs: Int
    public var softDropGraceMs: Int
    public var ruleset: Ruleset
    public var rules: RulesConfig

    public init(
        tickMs: Int = 16,
        softDropMultiplier: Int = 10,
        lockDelayMs: Int = 450,
        lockResetLimit: Int = 15,
        baseDropMs: Int = 1000,
        softDropGraceMs: Int = 150,
        ruleset: Ruleset = .classic,
        rules: RulesConfig = RulesConfig()
    ) {
        self.tickMs = tickMs
        self.softDropMultiplier = softDropMultiplier
        self.lockDelayMs = lockDelayMs
        self.lockResetLimit = lockResetLimit
        self.baseDropMs = baseDropMs
        self.softDropGraceMs = softDropGraceMs
        self.ruleset = ruleset
        self.rules = rules
    }
}
