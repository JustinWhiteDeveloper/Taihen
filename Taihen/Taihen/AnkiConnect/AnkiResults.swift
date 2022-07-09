import Foundation

struct AnkiQueryResult: Codable, Equatable {
    var result: [Int]
    var error: String?
}

struct AnkiCardInfoResultItem: Codable, Equatable {
    var cardId: Int
    var due: Int
    var reps: Int
    
    var isNewCard: Bool {
        return reps == 0
    }
}

struct AnkiCardInfoResult: Codable, Equatable {
    var result: [AnkiCardInfoResultItem]
    var error: String?
}
