import Core
import AVFoundation

public final class AudioEngine {
    private let baseURL: URL?
    private var players: [String: AVAudioPlayer]

    public init(baseURL: URL? = nil) {
        self.baseURL = baseURL
        self.players = [:]
    }

    public func play(_ event: SoundEvent, masterVolume: Double = 1.0) {
        guard let fileName = SoundEventMapper.fileName(for: event) else { return }
        let soundURL = resolveURL(for: event, fileName: fileName)
        let player: AVAudioPlayer
        if let cached = players[fileName] {
            player = cached
        } else {
            guard let created = try? AVAudioPlayer(contentsOf: soundURL) else { return }
            created.prepareToPlay()
            players[fileName] = created
            player = created
        }
        player.volume = resolvedVolume(for: event, master: masterVolume)
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

    public func resolvedVolume(for event: SoundEvent, master: Double) -> Float {
        let gain = SoundEventMapper.gain(for: event)
        let clamped = min(max(master * gain, 0), 1)
        return Float(clamped)
    }
}
