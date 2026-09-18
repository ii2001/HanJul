import Foundation

struct Quote: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let text: String
    let author: String
}
