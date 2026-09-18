import Foundation
import SwiftData

@Model
final class FavoriteQuote {
    @Attribute(.unique) var quoteID: String
    var text: String
    var author: String
    var createdAt: Date

    init(quote: Quote, createdAt: Date = .now) {
        quoteID = quote.id
        text = quote.text
        author = quote.author
        self.createdAt = createdAt
    }
}
