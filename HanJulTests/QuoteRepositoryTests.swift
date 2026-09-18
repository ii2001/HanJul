import Foundation
import XCTest
@testable import HanJul

final class QuoteRepositoryTests: XCTestCase {
    func test_decodesQuotes() throws {
        let data = Data(#"[{"id":"1","text":"한 줄","author":"작가"}]"#.utf8)

        let repository = try QuoteRepository(data: data)

        XCTAssertEqual(repository.quotes, [Quote(id: "1", text: "한 줄", author: "작가")])
    }

    func test_rejectsEmptyQuoteList() {
        XCTAssertThrowsError(try QuoteRepository(data: Data("[]".utf8))) { error in
            XCTAssertEqual(error as? QuoteRepository.Error, .empty)
        }
    }

    func test_bundledCatalogContains300UniqueQuotes() throws {
        let quotes = try QuoteRepository().quotes

        XCTAssertEqual(quotes.count, 300)
        XCTAssertEqual(Set(quotes.map(\.id)).count, 300)
        XCTAssertEqual(Set(quotes.map(\.text)).count, 300)
    }
}
