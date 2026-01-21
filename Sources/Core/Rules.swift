public enum Ruleset: Equatable {
    case classic
    case modern
}

public struct RulesConfig: Equatable {
    public var classicLineScores: [Int]
    public var tSpinFull: [Int]
    public var tSpinMini: [Int]
    public var comboBase: Int
    public var b2bBonusNum: Int
    public var b2bBonusDen: Int

    public init(
        classicLineScores: [Int] = [40, 100, 300, 1200],
        tSpinFull: [Int] = [400, 800, 1200, 1600],
        tSpinMini: [Int] = [100, 200, 400],
        comboBase: Int = 50,
        b2bBonusNum: Int = 3,
        b2bBonusDen: Int = 2
    ) {
        self.classicLineScores = classicLineScores
        self.tSpinFull = tSpinFull
        self.tSpinMini = tSpinMini
        self.comboBase = comboBase
        self.b2bBonusNum = b2bBonusNum
        self.b2bBonusDen = b2bBonusDen
    }
}
