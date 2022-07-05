import Foundation

struct FindCardTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: String]
}

struct CardInfoTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: [Int]]
}

struct GuiBrowseTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: String]
}

extension FindCardTemplate {
    static func findCardsWithExpression(_ expression: String) -> FindCardTemplate {
        return FindCardTemplate(action: "findCards", version: 6, params: ["query": expression])
    }
}

extension CardInfoTemplate {
    static func getCardInfoWithCards(_ cards: [Int]) -> CardInfoTemplate {
        return CardInfoTemplate(action: "cardsInfo", version: 6, params: ["cards": cards])
    }
}

extension GuiBrowseTemplate {
    static func getCardsWithQuery(_ query: String) -> GuiBrowseTemplate {
        return GuiBrowseTemplate(action: "guiBrowse", version: 6, params: ["query": query])
    }
}
