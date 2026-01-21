import Core
import AVFoundation

public protocol AudioPlaying {
    func play(_ event: SoundEvent, masterVolume: Double, gainOverride: Double?)
    func setAmbientLoop(enabled: Bool, masterVolume: Double)
    func setAmbientDucking(enabled: Bool)
}

public protocol SoundBuffer {
    var format: AVAudioFormat { get }
    var pcmBuffer: AVAudioPCMBuffer { get }
}

public protocol AudioPlaybackNode {
    var volume: Float { get set }
    var isPlaying: Bool { get }
    func schedule(_ buffer: SoundBuffer, loops: Bool)
    func play()
    func stop()
}

public protocol AudioEngineBackend {
    func loadBuffer(from url: URL) -> SoundBuffer?
    func makePlayerNode() -> AudioPlaybackNode
    func attach(_ node: AudioPlaybackNode)
    func connect(_ node: AudioPlaybackNode, format: AVAudioFormat)
    func startIfNeeded()
}

private final class AVAudioBufferAdapter: SoundBuffer {
    let pcmBuffer: AVAudioPCMBuffer

    init(buffer: AVAudioPCMBuffer) {
        self.pcmBuffer = buffer
    }

    var format: AVAudioFormat { pcmBuffer.format }
}

private final class AVAudioPlayerNodeAdapter: AudioPlaybackNode {
    fileprivate let node: AVAudioPlayerNode

    init(node: AVAudioPlayerNode) {
        self.node = node
    }

    var volume: Float {
        get { node.volume }
        set { node.volume = newValue }
    }

    var isPlaying: Bool { node.isPlaying }

    func schedule(_ buffer: SoundBuffer, loops: Bool) {
        let options: AVAudioPlayerNodeBufferOptions = loops ? .loops : .interrupts
        node.scheduleBuffer(buffer.pcmBuffer, at: nil, options: options, completionHandler: nil)
    }

    func play() {
        node.play()
    }

    func stop() {
        node.stop()
    }
}

private final class AVAudioEngineBackend: AudioEngineBackend {
    private let engine: AVAudioEngine
    private var isStarted: Bool

    init(engine: AVAudioEngine = AVAudioEngine()) {
        self.engine = engine
        self.isStarted = false
    }

    func loadBuffer(from url: URL) -> SoundBuffer? {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        let frameCapacity = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCapacity) else { return nil }
        do {
            try file.read(into: buffer)
        } catch {
            return nil
        }
        return AVAudioBufferAdapter(buffer: buffer)
    }

    func makePlayerNode() -> AudioPlaybackNode {
        AVAudioPlayerNodeAdapter(node: AVAudioPlayerNode())
    }

    func attach(_ node: AudioPlaybackNode) {
        guard let adapter = node as? AVAudioPlayerNodeAdapter else { return }
        engine.attach(adapter.node)
    }

    func connect(_ node: AudioPlaybackNode, format: AVAudioFormat) {
        guard let adapter = node as? AVAudioPlayerNodeAdapter else { return }
        engine.connect(adapter.node, to: engine.mainMixerNode, format: format)
    }

    func startIfNeeded() {
        guard !isStarted else { return }
        engine.prepare()
        do {
            try engine.start()
            isStarted = true
        } catch {
            isStarted = false
        }
    }
}

public final class AudioEngine: AudioPlaying {
    private let baseURL: URL?
    private let maxPlayersPerSound: Int
    private let backend: AudioEngineBackend
    private var buffers: [String: SoundBuffer]
    private var players: [String: [AudioPlaybackNode]]
    private var ambientPlayer: AudioPlaybackNode?
    private var ambientBuffer: SoundBuffer?
    private var ambientEnabled: Bool = false
    private var ambientDucked: Bool = false
    private var ambientMasterVolume: Double = 1.0
    private let ambientFileName = "ambient_loop.wav"
    private let ambientGain: Double = 0.2
    private let ambientDuckMultiplier: Double = 0.35

    public init(
        baseURL: URL? = nil,
        maxPlayersPerSound: Int = 4,
        backend: AudioEngineBackend? = nil
    ) {
        self.baseURL = baseURL
        self.maxPlayersPerSound = max(1, maxPlayersPerSound)
        self.backend = backend ?? AVAudioEngineBackend()
        self.buffers = [:]
        self.players = [:]
        preloadBuffers()
    }

    public func play(_ event: SoundEvent, masterVolume: Double = 1.0, gainOverride: Double? = nil) {
        guard let fileName = SoundEventMapper.fileName(for: event) else { return }
        guard let buffer = buffers[fileName] ?? loadBuffer(fileName: fileName) else { return }
        var pool = players[fileName] ?? []
        var player: AudioPlaybackNode
        if let idle = pool.first(where: { !$0.isPlaying }) {
            player = idle
        } else if pool.count < maxPlayersPerSound {
            let created = backend.makePlayerNode()
            backend.attach(created)
            backend.connect(created, format: buffer.format)
            pool.append(created)
            player = created
        } else if let fallback = pool.first {
            player = fallback
        } else {
            return
        }
        players[fileName] = pool
        backend.startIfNeeded()
        player.volume = resolvedVolume(for: event, master: masterVolume, gainOverride: gainOverride)
        player.schedule(buffer, loops: false)
        player.play()
    }

    public func setAmbientLoop(enabled: Bool, masterVolume: Double = 1.0) {
        ambientEnabled = enabled
        ambientMasterVolume = masterVolume
        guard enabled else {
            ambientPlayer?.stop()
            ambientPlayer?.volume = 0
            return
        }
        let buffer = ambientBuffer ?? loadBuffer(fileName: ambientFileName)
        guard let buffer else { return }
        ambientBuffer = buffer
        if ambientPlayer == nil {
            let created = backend.makePlayerNode()
            backend.attach(created)
            backend.connect(created, format: buffer.format)
            ambientPlayer = created
        }
        backend.startIfNeeded()
        updateAmbientVolume()
        if ambientPlayer?.isPlaying == false {
            ambientPlayer?.schedule(buffer, loops: true)
            ambientPlayer?.play()
        }
    }

    public func setAmbientDucking(enabled: Bool) {
        guard ambientDucked != enabled else { return }
        ambientDucked = enabled
        updateAmbientVolume()
    }

    public func resolveURL(for event: SoundEvent) -> URL? {
        guard let fileName = SoundEventMapper.fileName(for: event) else { return nil }
        return resolveURL(fileName: fileName)
    }

    private func resolveURL(fileName: String) -> URL {
        if let baseURL {
            return baseURL.appendingPathComponent(fileName)
        }
        return Bundle.main.url(forResource: fileName, withExtension: nil) ?? URL(fileURLWithPath: fileName)
    }

    private func preloadBuffers() {
        for fileName in SoundEventMapper.allFileNames {
            let url = resolveURL(fileName: fileName)
            if let buffer = backend.loadBuffer(from: url) {
                buffers[fileName] = buffer
            }
        }
    }

    private func loadBuffer(fileName: String) -> SoundBuffer? {
        let url = resolveURL(fileName: fileName)
        guard let buffer = backend.loadBuffer(from: url) else { return nil }
        buffers[fileName] = buffer
        return buffer
    }

    private func updateAmbientVolume() {
        guard ambientEnabled else { return }
        let duck = ambientDucked ? ambientDuckMultiplier : 1
        let volume = min(max(ambientMasterVolume * ambientGain * duck, 0), 1)
        ambientPlayer?.volume = Float(volume)
    }

    public func resolvedVolume(for event: SoundEvent, master: Double, gainOverride: Double? = nil) -> Float {
        let gain = gainOverride ?? SoundEventMapper.gain(for: event)
        let clamped = min(max(master * gain, 0), 1)
        return Float(clamped)
    }
}
