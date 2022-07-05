import Foundation

// {"title":"JMdict (English)","format":3,"revision":"jmdict4","sequenced":true}
struct TaihenJSONDictionaryIndex: Codable, Equatable {
    let title: String
    let format: Int
    let revision: String
    let sequenced: Bool
}

// ["news","frequent",-2,"appears frequently in Mainichi Shimbun",0]
struct TaihenJSONDictionaryTag: Codable, Equatable {

    var shortName: String
    
    //"frequent", "popular", "partOfSpeech", "", "archaism", "expression"
    var extraInfo: String
    
    // Color (-10,-5,-4,-3,-2,0)
    var color: Int
    
    // i.e Buddhism, Christanity, Gohan verb
    var tagDescription: String
    
    // Assumed meaning (-5,0,10)
    var piority: Int
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.shortName = try container.decode(String.self)
        self.extraInfo = try container.decode(String.self)
        self.color = try container.decode(Int.self)
        self.tagDescription = try container.decode(String.self)
        self.piority = try container.decode(Int.self)
    }
    
    init(shortName: String,
         extraInfo: String,
         color: Int,
         tagDescription: String,
         piority: Int) {
        
        self.shortName = shortName
        self.extraInfo = extraInfo
        self.color = color
        self.tagDescription = tagDescription
        self.piority = piority
    }
}

enum QuantumValue: Decodable {
    
    case string(String),
         dictionary([String: String])
    
    init(from decoder: Decoder) throws {
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
        } else if let dict = try? decoder.singleValueContainer().decode([String: String].self) {
            self = .dictionary(dict)
        } else {
            self = .string("")
        }
    }
    
    var stringValue: String? {
        switch self {
        case .string(let value): return value
        case .dictionary(_): return nil
        }
    }
    
    var dictionaryValue: [String: String]? {
        switch self {
        case .string(_): return nil
        case .dictionary(let value): return value
        }
    }
}

// ["内包","ないほう","n vs vt","vs",610,["connotation","comprehension","intension"],1459170,"P news"]
struct TaihenJSONDictionaryTerm: Codable, Equatable {
    let term: String
    let kana: String
    let meaningTags: [String]
    
    // Assumed, i.e "","adj-i","v1","v5","v5 v1"...
    let explicitType: String
    let unknownInteger: Int
    let meanings: [String]
    let extraMeanings: [[String: String]]
    let index: Int
    let termTags: [String]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.term = try container.decode(String.self)
        self.kana = try container.decode(String.self)
        self.meaningTags = try container.decode(String.self)
            .components(separatedBy: " ")
            .filter({ $0.count > 0 })
        self.explicitType = try container.decode(String.self)
        self.unknownInteger = try container.decode(Int.self)
        
        //Filter out JSON i.e images
        let meaningObject = try container.decode([QuantumValue].self)
        
        self.meanings = meaningObject.compactMap({ $0.stringValue })
        self.extraMeanings = meaningObject.compactMap({ $0.dictionaryValue })

        self.index = try container.decode(Int.self)
        self.termTags = try container.decode(String.self)
            .components(separatedBy: " ")
            .filter({ $0.count > 0 })
    }
    
    init(term: String,
         kana: String,
         definitionTags: [String],
         explicitType: String,
         unknownInteger: Int,
         meanings: [String],
         extraMeanings: [[String: String]],
         index: Int,
         classifications: [String]) {
        
        self.term = term
        self.kana = kana
        self.meaningTags = definitionTags
        self.explicitType = explicitType
        self.unknownInteger = unknownInteger
        self.meanings = meanings
        self.extraMeanings = extraMeanings
        self.index = index
        self.termTags = classifications
    }
}

protocol TaihenJSONDictionary {
    var name: String { get set }
    var format: Int { get set }
    var revision: String { get set }
    var sequenced: Bool { get set }
    
    var tags: [TaihenJSONDictionaryTag] { get set }
    var terms: [TaihenJSONDictionaryTerm] { get set }
}

class ConcreteTaihenJSONDictionary: TaihenJSONDictionary {
    var name: String = ""
    var format: Int = 0
    var revision: String = ""
    var sequenced: Bool = false
    
    var tags: [TaihenJSONDictionaryTag] = []
    var terms: [TaihenJSONDictionaryTerm] = []
}
