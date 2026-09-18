import Foundation

struct QuoteRepository: Sendable {
    enum Error: Swift.Error, Equatable {
        case resourceNotFound(String)
        case empty
    }

    let quotes: [Quote]

    init(data: Data) throws {
        let quotes = try JSONDecoder().decode([Quote].self, from: data)
        guard !quotes.isEmpty else { throw Error.empty }
        self.quotes = quotes
    }

    init(bundle: Bundle = .main, resource: String = "quotes") throws {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw Error.resourceNotFound(resource)
        }
        try self.init(data: Data(contentsOf: url))
    }
}
