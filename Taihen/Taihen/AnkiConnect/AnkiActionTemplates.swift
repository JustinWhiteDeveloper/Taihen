import Foundation

struct FindCardTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: String]
}

extension FindCardTemplate {
    static func findCardsWithExpression(_ expression: String) -> FindCardTemplate {
        return FindCardTemplate(action: "findCards", version: 6, params: ["query": expression])
    }
}

struct CardInfoTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: [Int]]
}

extension CardInfoTemplate {
    static func getCardInfoWithCards(_ cards: [Int]) -> CardInfoTemplate {
        return CardInfoTemplate(action: "cardsInfo", version: 6, params: ["cards": cards])
    }
}

struct GuiBrowseTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: String]
}

extension GuiBrowseTemplate {
    static func getCardsWithQuery(_ query: String) -> GuiBrowseTemplate {
        return GuiBrowseTemplate(action: "guiBrowse", version: 6, params: ["query": query])
    }
}

struct AddCardDetailAudioParams: Codable {
    var url: String
    var filename: String
    var fields: [String]
}

struct AddCardDetailParams: Codable {
    var deckName: String
    var modelName: String
    var fields: [String: String]
    var tags: [String]
    var audio: AddCardDetailAudioParams?
}

struct AddCardParams: Codable {
    var note: AddCardDetailParams
}

struct AddCardTemplate: Codable {
    var action: String
    var version: Int
    var params: AddCardParams
}

extension AddCardTemplate {
    static func addCard(deckName: String,
                        modelName: String,
                        frontContent: String,
                        backContent: String,
                        audioURL: String? = nil) -> AddCardTemplate {
        
        var audioParams: AddCardDetailAudioParams? = nil
        
        if let audioURL = audioURL {
           audioParams = AddCardDetailAudioParams(url: audioURL,
                                                  filename: "taihen_" + audioURL.md5 + ".mp3",
                                                  fields: ["Back"])
        }
        
        var fields: [String: String] = [:]
        
        if modelName == "Basic" {
            fields = ["Front": frontContent,
                      "Back": backContent]
        } else {
            fields = ["Expression": frontContent,
                      "Meaning": backContent]
        }
        

        let params = AddCardParams(note: AddCardDetailParams(deckName: deckName,
                                                             modelName: modelName,
                                                             fields: fields,
                                                             tags: ["taihen"],
                                                             audio: audioParams))
        
        return AddCardTemplate(action: "addNote", version: 6, params: params)
    }
}
