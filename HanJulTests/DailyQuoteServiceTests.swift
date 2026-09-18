import Foundation
import XCTest
@testable import HanJul

final class DailyQuoteServiceTests: XCTestCase {
    private let quotes = (0..<10).map {
        Quote(id: String($0), text: "명언 \($0)", author: "작가")
    }

    func test_returnsSameQuoteThroughoutCalendarDay() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Seoul"))
        let repository = try QuoteRepository(data: JSONEncoder().encode(quotes))
        let service = DailyQuoteService(repository: repository, calendar: calendar)
        let morning = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 18, hour: 0)))
        let night = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 18, hour: 23, minute: 59)))

        XCTAssertEqual(service.quote(for: morning), service.quote(for: night))
    }

    func test_selectionIsDeterministic() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let repository = try QuoteRepository(data: JSONEncoder().encode(quotes))
        let service = DailyQuoteService(repository: repository, calendar: calendar)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 18)))

        XCTAssertEqual(service.quote(for: date).id, "4")
    }

    func test_returnsThreeUniqueQuotesPerInstallAndDay() throws {
        let repository = try QuoteRepository(data: JSONEncoder().encode(quotes))
        let service = DailyQuoteService(repository: repository)
        let date = Date(timeIntervalSinceReferenceDate: 0)

        let selected = service.quotes(for: date, seed: "install-a", limit: 3)

        XCTAssertEqual(selected.count, 3)
        XCTAssertEqual(Set(selected.map(\.id)).count, 3)
        XCTAssertEqual(selected, service.quotes(for: date, seed: "install-a", limit: 3))
        XCTAssertNotEqual(selected, service.quotes(for: date, seed: "install-b", limit: 3))
    }

    func test_artworkSelectionIsDeterministic() {
        let quote = Quote(id: "same-quote", text: "명언", author: "작가")

        XCTAssertEqual(
            QuoteArtwork.daily.imageName(for: quote),
            QuoteArtwork.daily.imageName(for: quote)
        )
        XCTAssertNotNil(QuoteArtwork.daily.imageName(for: quote))
    }
}
