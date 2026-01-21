public struct SimpleRng {
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed
    }

    public mutating func nextUInt32() -> UInt32 {
        state = state &* 1664525 &+ 1013904223
        return UInt32(truncatingIfNeeded: state >> 16)
    }

    mutating func nextRange(_ upper: Int) -> Int {
        guard upper > 0 else { return 0 }
        return Int(nextUInt32()) % upper
    }
}

public enum QueueRng {
    public static func refillBag(rng: inout SimpleRng, queue: inout [TetrominoType]) {
        var bag: [TetrominoType] = [.i, .o, .t, .s, .z, .j, .l]
        for i in stride(from: bag.count - 1, through: 1, by: -1) {
            let j = rng.nextRange(i + 1)
            bag.swapAt(i, j)
        }
        queue.append(contentsOf: bag)
    }

    public static func ensureQueue(rng: inout SimpleRng, queue: inout [TetrominoType], minimum: Int = 5) {
        while queue.count < minimum {
            refillBag(rng: &rng, queue: &queue)
        }
    }
}
