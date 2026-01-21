import XCTest
import AVFoundation
@testable import UI
@testable import Core

final class AudioEnginePlaybackTests: XCTestCase {
    func testAudioEnginePreloadsBuffers() {
        let backend = FakeAudioBackend()
        let baseURL = URL(fileURLWithPath: "/tmp/audio")

        _ = AudioEngine(baseURL: baseURL, maxPlayersPerSound: 2, backend: backend)

        let expected = SoundEventMapper.allFileNames
            .map { baseURL.appendingPathComponent($0).path }
            .sorted()
        let loaded = backend.loadedURLs.map(\.path).sorted()
        XCTAssertEqual(loaded, expected)
    }

    func testAudioEngineReusesIdlePlayer() {
        let backend = FakeAudioBackend()
        let engine = AudioEngine(baseURL: nil, maxPlayersPerSound: 2, backend: backend)

        engine.play(.move)
        XCTAssertEqual(backend.nodes.count, 1)
        backend.nodes[0].isPlaying = false

        engine.play(.move)
        XCTAssertEqual(backend.nodes.count, 1)
        XCTAssertEqual(backend.nodes[0].playCount, 2)
    }

    func testAudioEngineCreatesNewPlayerWhenBusy() {
        let backend = FakeAudioBackend()
        let engine = AudioEngine(baseURL: nil, maxPlayersPerSound: 2, backend: backend)

        engine.play(.rotate)
        engine.play(.rotate)

        XCTAssertEqual(backend.nodes.count, 2)
        XCTAssertEqual(backend.nodes[0].playCount, 1)
        XCTAssertEqual(backend.nodes[1].playCount, 1)
    }

    func testAudioEngineReusesPlayerWhenAtCap() {
        let backend = FakeAudioBackend()
        let engine = AudioEngine(baseURL: nil, maxPlayersPerSound: 1, backend: backend)

        engine.play(.lineClear(1))
        engine.play(.lineClear(1))

        XCTAssertEqual(backend.nodes.count, 1)
        XCTAssertEqual(backend.nodes[0].playCount, 2)
    }
}

private final class FakeAudioBackend: AudioEngineBackend {
    var loadedURLs: [URL] = []
    var nodes: [FakeAudioNode] = []
    private let buffer: FakeAudioBuffer

    init() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1)!
        pcmBuffer.frameLength = 1
        self.buffer = FakeAudioBuffer(buffer: pcmBuffer)
    }

    func loadBuffer(from url: URL) -> SoundBuffer? {
        loadedURLs.append(url)
        return buffer
    }

    func makePlayerNode() -> AudioPlaybackNode {
        let node = FakeAudioNode()
        nodes.append(node)
        return node
    }

    func attach(_ node: AudioPlaybackNode) {}

    func connect(_ node: AudioPlaybackNode, format: AVAudioFormat) {}

    func startIfNeeded() {}
}

private final class FakeAudioBuffer: SoundBuffer {
    let pcmBuffer: AVAudioPCMBuffer

    init(buffer: AVAudioPCMBuffer) {
        self.pcmBuffer = buffer
    }

    var format: AVAudioFormat { pcmBuffer.format }
}

private final class FakeAudioNode: AudioPlaybackNode {
    var volume: Float = 1.0
    var isPlaying: Bool = false
    private(set) var scheduleCount: Int = 0
    private(set) var playCount: Int = 0

    func schedule(_ buffer: SoundBuffer) {
        scheduleCount += 1
    }

    func play() {
        playCount += 1
        isPlaying = true
    }
}
