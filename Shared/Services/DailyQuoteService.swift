import CryptoKit
import Foundation

struct DailyQuoteService: Sendable {
    private let quotes: [Quote]
    private let calendar: Calendar

    init(repository: QuoteRepository, calendar: Calendar = .current) {
        quotes = repository.quotes
        self.calendar = calendar
    }

    func quote(for date: Date = .now, seed: String = "") -> Quote {
        quotes(for: date, seed: seed, limit: 1)[0]
    }

    func quotes(for date: Date = .now, seed: String, limit: Int) -> [Quote] {
        let components = calendar.dateComponents([.era, .year, .month, .day], from: date)
        let day = "\(components.era ?? 0)-\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
        let dailySeed = seed.isEmpty ? day : "\(day)-\(seed)"
        var selectedIndices = Set<Int>()

        return (0..<min(max(limit, 0), quotes.count)).map { offset in
            let selectionSeed = offset == 0 ? dailySeed : "\(dailySeed)-\(offset)"
            let value = SHA256.hash(data: Data(selectionSeed.utf8))
                .prefix(8)
                .reduce(UInt64.zero) { ($0 << 8) | UInt64($1) }
            var index = Int(value % UInt64(quotes.count))
            while selectedIndices.contains(index) {
                index = (index + 1) % quotes.count
            }
            selectedIndices.insert(index)
            return quotes[index]
        }
    }
}
