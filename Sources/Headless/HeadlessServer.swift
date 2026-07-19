import Foundation
import Runtime

public protocol HeadlessScheduling: Sendable {
    var nowNanoseconds: UInt64 { get }
    func sleep(untilNanoseconds deadline: UInt64)
}

public struct SystemHeadlessScheduler: HeadlessScheduling {
    public init() {}

    public var nowNanoseconds: UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }

    public func sleep(untilNanoseconds deadline: UInt64) {
        let now = nowNanoseconds
        guard deadline > now else { return }
        Thread.sleep(forTimeInterval: Double(deadline - now) / 1_000_000_000)
    }
}

public struct ImmediateHeadlessScheduler: HeadlessScheduling {
    public init() {}

    public var nowNanoseconds: UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }

    public func sleep(untilNanoseconds deadline: UInt64) {}
}

public final class HeadlessServer {
    private let runtime: GameRuntime
    private let scheduler: any HeadlessScheduling
    private let stepMs: Int
    private let maxCatchUpMs: Int
    private let restartsOnGameOver: Bool

    public init(
        runtime: GameRuntime,
        scheduler: any HeadlessScheduling = SystemHeadlessScheduler(),
        stepMs: Int = GameRuntime.defaultStepMs,
        maxCatchUpMs: Int = GameRuntime.defaultMaxFrameMs,
        restartsOnGameOver: Bool = false
    ) {
        self.runtime = runtime
        self.scheduler = scheduler
        self.stepMs = max(stepMs, 1)
        self.maxCatchUpMs = max(maxCatchUpMs, 0)
        self.restartsOnGameOver = restartsOnGameOver
    }

    public func run(
        maxSteps: Int? = nil,
        while shouldContinue: () -> Bool = { true }
    ) {
        let stepNanoseconds = UInt64(stepMs) * 1_000_000
        let maxLagNanoseconds = UInt64(maxCatchUpMs) * 1_000_000
        var deadline = scheduler.nowNanoseconds
        var completedSteps = 0

        while (maxSteps.map { completedSteps < $0 } ?? true) && shouldContinue() {
            deadline = deadline.addingReportingOverflow(stepNanoseconds).partialValue
            scheduler.sleep(untilNanoseconds: deadline)
            if restartsOnGameOver, runtime.snapshot.gameOver {
                runtime.enqueue(.restart)
            }
            runtime.advance(frameMs: stepMs)
            completedSteps += 1

            let now = scheduler.nowNanoseconds
            if now > deadline, now - deadline > maxLagNanoseconds {
                deadline = now
            }
        }
    }
}

public struct HeadlessServerOptions: Equatable, Sendable {
    public enum ParseError: Error, Equatable {
        case missingValue(String)
        case invalidValue(String)
        case unknownArgument(String)
    }

    public enum ValidationError: Error, Equatable {
        case fastModeRequiresDisabledAdapter
    }

    public var seed: UInt64
    public var maxSteps: Int?
    public var runsAsFastAsPossible: Bool
    public var restartsOnGameOver: Bool
    public var helpRequested: Bool

    public init(
        seed: UInt64 = 1,
        maxSteps: Int? = nil,
        runsAsFastAsPossible: Bool = false,
        restartsOnGameOver: Bool = false,
        helpRequested: Bool = false
    ) {
        self.seed = seed
        self.maxSteps = maxSteps
        self.runsAsFastAsPossible = runsAsFastAsPossible
        self.restartsOnGameOver = restartsOnGameOver
        self.helpRequested = helpRequested
    }

    public static func parse(_ arguments: [String]) throws -> HeadlessServerOptions {
        var options = HeadlessServerOptions()
        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--seed":
                let value = try nextValue(after: argument, arguments: arguments, index: &index)
                guard let seed = UInt64(value) else { throw ParseError.invalidValue(argument) }
                options.seed = seed
            case "--steps":
                let value = try nextValue(after: argument, arguments: arguments, index: &index)
                guard let steps = Int(value), steps > 0 else { throw ParseError.invalidValue(argument) }
                options.maxSteps = steps
            case "--fast":
                options.runsAsFastAsPossible = true
            case "--auto-restart":
                options.restartsOnGameOver = true
            case "--help", "-h":
                options.helpRequested = true
            default:
                throw ParseError.unknownArgument(argument)
            }
            index += 1
        }
        return options
    }

    public func validate(adapterEnabled: Bool) throws {
        if runsAsFastAsPossible, adapterEnabled {
            throw ValidationError.fastModeRequiresDisabledAdapter
        }
    }

    private static func nextValue(
        after argument: String,
        arguments: [String],
        index: inout Int
    ) throws -> String {
        index += 1
        guard index < arguments.count else { throw ParseError.missingValue(argument) }
        return arguments[index]
    }
}
