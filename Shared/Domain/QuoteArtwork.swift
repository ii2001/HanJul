import CryptoKit
import Foundation

enum QuoteArtwork: String, CaseIterable, Identifiable, Sendable {
    case daily
    case dawn
    case moon
    case spring
    case autumn
    case winter
    case hidden

    static let appGroupID = "group.com.ii2001.HanJul"
    static let preferenceKey = "quoteArtwork"
    static let defaults = UserDefaults(suiteName: appGroupID) ?? .standard

    private static let imageNames = [
        "ArtworkDawn",
        "ArtworkMoon",
        "ArtworkSpring",
        "ArtworkAutumn",
        "ArtworkWinter"
    ]

    var id: Self { self }

    var title: String {
        switch self {
        case .daily: "오늘의 배경"
        case .dawn: "안개 산"
        case .moon: "달빛 호수"
        case .spring: "봄꽃"
        case .autumn: "가을 들판"
        case .winter: "겨울 숲"
        case .hidden: "배경 없음"
        }
    }

    func imageName(for quote: Quote) -> String? {
        switch self {
        case .daily:
            let digest = SHA256.hash(data: Data(quote.id.utf8))
            let index = digest.prefix(1).reduce(0) { _, byte in Int(byte) }
            return Self.imageNames[index % Self.imageNames.count]
        case .hidden:
            return nil
        default:
            return "Artwork\(rawValue.capitalized)"
        }
    }

    static var selected: Self {
        Self(rawValue: defaults.string(forKey: preferenceKey) ?? "") ?? .daily
    }
}
