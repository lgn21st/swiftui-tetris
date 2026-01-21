import Core
import AVFoundation

public final class AudioEngine {
    private let baseURL: URL?
    private var players: [String: AVAudioPlayer]

    public init(baseURL: URL? = nil) {
        self.baseURL = baseURL
        self.players = [:]
    }

    public func play(_ event: SoundEvent) {
        guard let fileName = SoundEventMapper.fileName(for: event) else { return }
        let url: URL?
        if let baseURL {
            url = baseURL.appendingPathComponent(fileName)
        } else {
            url = Bundle.main.url(forResource: fileName, withExtension: nil)
        }
        guard let soundURL = url else { return }
        let player: AVAudioPlayer
        if let cached = players[fileName] {
            player = cached
        } else {
            guard let created = try? AVAudioPlayer(contentsOf: soundURL) else { return }
            created.prepareToPlay()
            players[fileName] = created
            player = created
        }
        player.currentTime = 0
        player.play()
    }
}
