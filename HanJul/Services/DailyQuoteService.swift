import CryptoKit
import Foundation

struct DailyQuoteService: Sendable {
    private let quotes: [Quote]
    private let calendar: Calendar

    init(repository: QuoteRepository, calendar: Calendar = .current) {
        quotes = repository.quotes
        self.calendar = calendar
    }

    func quote(for date: Date = .now) -> Quote {
        let components = calendar.dateComponents([.era, .year, .month, .day], from: date)
        let day = "\(components.era ?? 0)-\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
        let digest = SHA256.hash(data: Data(day.utf8))
        let value = digest.prefix(8).reduce(UInt64.zero) { ($0 << 8) | UInt64($1) }
        return quotes[Int(value % UInt64(quotes.count))]
    }
}
