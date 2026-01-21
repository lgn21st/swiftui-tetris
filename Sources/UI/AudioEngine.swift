import Core
import AVFoundation

public protocol AudioPlayer {
    var volume: Float { get set }
    var currentTime: TimeInterval { get set }
    var isPlaying: Bool { get }
    func prepareToPlay()
    func play()
}

private final class AVAudioPlayerAdapter: AudioPlayer {
    private let player: AVAudioPlayer

    init(player: AVAudioPlayer) {
        self.player = player
    }

    var volume: Float {
        get { player.volume }
        set { player.volume = newValue }
    }

    var currentTime: TimeInterval {
        get { player.currentTime }
        set { player.currentTime = newValue }
    }

    var isPlaying: Bool { player.isPlaying }

    func prepareToPlay() {
        player.prepareToPlay()
    }

    func play() {
        player.play()
    }
}

public final class AudioEngine {
    private let baseURL: URL?
    private let maxPlayersPerSound: Int
    private let playerFactory: (URL) -> AudioPlayer?
    private var players: [String: [AudioPlayer]]

    public init(
        baseURL: URL? = nil,
        maxPlayersPerSound: Int = 4,
        playerFactory: @escaping (URL) -> AudioPlayer? = AudioEngine.defaultFactory
    ) {
        self.baseURL = baseURL
        self.maxPlayersPerSound = max(1, maxPlayersPerSound)
        self.playerFactory = playerFactory
        self.players = [:]
    }

    public func play(_ event: SoundEvent, masterVolume: Double = 1.0, gainOverride: Double? = nil) {
        guard let fileName = SoundEventMapper.fileName(for: event) else { return }
        let soundURL = resolveURL(for: event, fileName: fileName)
        var pool = players[fileName] ?? []
        var player: AudioPlayer
        if let idle = pool.first(where: { !$0.isPlaying }) {
            player = idle
        } else if pool.count < maxPlayersPerSound, let created = playerFactory(soundURL) {
            created.prepareToPlay()
            pool.append(created)
            player = created
        } else if let fallback = pool.first {
            player = fallback
        } else {
            return
        }
        players[fileName] = pool
        player.volume = resolvedVolume(for: event, master: masterVolume, gainOverride: gainOverride)
        player.currentTime = 0
        player.play()
    }

    public func resolveURL(for event: SoundEvent) -> URL? {
        guard let fileName = SoundEventMapper.fileName(for: event) else { return nil }
        return resolveURL(for: event, fileName: fileName)
    }

    private func resolveURL(for event: SoundEvent, fileName: String) -> URL {
        if let baseURL {
            return baseURL.appendingPathComponent(fileName)
        }
        return Bundle.main.url(forResource: fileName, withExtension: nil) ?? URL(fileURLWithPath: fileName)
    }

    public func resolvedVolume(for event: SoundEvent, master: Double, gainOverride: Double? = nil) -> Float {
        let gain = gainOverride ?? SoundEventMapper.gain(for: event)
        let clamped = min(max(master * gain, 0), 1)
        return Float(clamped)
    }

    public static func defaultFactory(url: URL) -> AudioPlayer? {
        guard let created = try? AVAudioPlayer(contentsOf: url) else { return nil }
        return AVAudioPlayerAdapter(player: created)
    }
}
