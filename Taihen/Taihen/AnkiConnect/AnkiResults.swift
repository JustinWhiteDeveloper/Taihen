import Foundation

struct AnkiQueryResult: Codable, Equatable {
    var result: [Int]
    var error: String?
}

struct AnkiCardInfoResultItem: Codable, Equatable {
    var cardId: Int
    var due: Int
}

struct AnkiCardInfoResult: Codable, Equatable {
    var result: [AnkiCardInfoResultItem]
    var error: String?
}
