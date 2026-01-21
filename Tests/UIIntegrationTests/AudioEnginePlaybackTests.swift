import XCTest
@testable import UI
@testable import Core

final class AudioEnginePlaybackTests: XCTestCase {
    func testAudioEngineReusesIdlePlayer() {
        var created: [FakeAudioPlayer] = []
        let engine = AudioEngine(
            baseURL: nil,
            maxPlayersPerSound: 2,
            playerFactory: { _ in
                let player = FakeAudioPlayer()
                created.append(player)
                return player
            }
        )

        engine.play(.move)
        XCTAssertEqual(created.count, 1)
        created[0].isPlaying = false

        engine.play(.move)
        XCTAssertEqual(created.count, 1)
        XCTAssertEqual(created[0].playCount, 2)
    }

    func testAudioEngineCreatesNewPlayerWhenBusy() {
        var created: [FakeAudioPlayer] = []
        let engine = AudioEngine(
            baseURL: nil,
            maxPlayersPerSound: 2,
            playerFactory: { _ in
                let player = FakeAudioPlayer()
                created.append(player)
                return player
            }
        )

        engine.play(.rotate)
        engine.play(.rotate)

        XCTAssertEqual(created.count, 2)
        XCTAssertEqual(created[0].playCount, 1)
        XCTAssertEqual(created[1].playCount, 1)
    }

    func testAudioEngineReusesPlayerWhenAtCap() {
        var created: [FakeAudioPlayer] = []
        let engine = AudioEngine(
            baseURL: nil,
            maxPlayersPerSound: 1,
            playerFactory: { _ in
                let player = FakeAudioPlayer()
                created.append(player)
                return player
            }
        )

        engine.play(.lineClear(1))
        engine.play(.lineClear(1))

        XCTAssertEqual(created.count, 1)
        XCTAssertEqual(created[0].playCount, 2)
    }
}

private final class FakeAudioPlayer: AudioPlayer {
    var volume: Float = 1.0
    var currentTime: TimeInterval = 0
    var isPlaying: Bool = false
    private(set) var prepareCount: Int = 0
    private(set) var playCount: Int = 0

    func prepareToPlay() {
        prepareCount += 1
    }

    func play() {
        playCount += 1
        isPlaying = true
    }
}
