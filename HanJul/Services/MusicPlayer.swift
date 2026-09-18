import AVFoundation
import Combine
import Foundation
import OSLog

enum LocalMusicLibrary {
    private static let supportedExtensions = ["mp3", "m4a", "wav", "aac"]

    static func bundledURLs(in bundle: Bundle = .main) -> [URL] {
        supportedExtensions
            .flatMap { bundle.urls(forResourcesWithExtension: $0, subdirectory: nil) ?? [] }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }

    static func today(
        in urls: [URL],
        date: Date = .now,
        calendar: Calendar = .current
    ) -> URL? {
        guard !urls.isEmpty else { return nil }
        let day = calendar.ordinality(of: .day, in: .era, for: date) ?? 1
        return urls[(day - 1) % urls.count]
    }
}

@MainActor
final class MusicPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "HanJul", category: "music")

    @Published private(set) var isPlaying = false
    @Published private(set) var trackTitle: String?

    private var player: AVAudioPlayer?

    override init() {
        super.init()
        load(trackURL: LocalMusicLibrary.today(in: LocalMusicLibrary.bundledURLs()))
    }

    init(trackURL: URL?) {
        super.init()
        load(trackURL: trackURL)
    }

    private func load(trackURL: URL?) {
        guard let trackURL else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: trackURL)
            player.delegate = self
            player.prepareToPlay()
            self.player = player
            trackTitle = trackURL.deletingPathExtension().lastPathComponent
        } catch {
            Self.logger.error("Music loading failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func play() -> Bool {
        guard let player, player.play() else { return false }
        isPlaying = true
        return true
    }

    func pause() -> Bool {
        guard let player, player.isPlaying else { return false }
        player.pause()
        isPlaying = false
        return true
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
