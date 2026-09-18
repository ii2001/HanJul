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

    func test_artworkSelectionIsDeterministic() {
        let quote = Quote(id: "same-quote", text: "명언", author: "작가")

        XCTAssertEqual(
            QuoteArtwork.daily.imageName(for: quote),
            QuoteArtwork.daily.imageName(for: quote)
        )
        XCTAssertNotNil(QuoteArtwork.daily.imageName(for: quote))
    }
}
