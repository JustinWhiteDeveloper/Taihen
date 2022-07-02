import Foundation

public struct TaihenCustomDictionaryTag: Codable, Equatable {
    public var shortName: String
    public var extraInfo: String
    public var color: Int
    public var tagDescription: String
    public var piority: Int
    
    // Optimised Coding keys for delaying better writing method
    enum CodingKeys: String, CodingKey {
        case shortName = "n"
        case extraInfo = "e"
        case color = "c"
        case tagDescription = "t"
        case piority = "p"
    }
    
    public init(shortName: String = "",
                extraInfo: String = "",
                color: Int = 0,
                tagDescription: String = "",
                piority: Int = 0) {
        self.shortName = shortName
        self.extraInfo = extraInfo
        self.color = color
        self.tagDescription = tagDescription
        self.piority = piority
    }
}

public struct TaihenCustomDictionaryTerm: Codable, Equatable {
    public let term: String
    public let kana: String
    public let meaningTags: [String]
    public let explicitType: String
    public let meanings: [String]
    public let extraMeanings: [[String: String]]
    public let index: Int
    public let termTags: [String]
    
    //temp
    public var dictionary: String?
    
    // Optimised Coding keys for delaying better writing method
    enum CodingKeys: String, CodingKey {
        case term = "t"
        case kana = "k"
        case meaningTags = "d"
        case explicitType = "e"
        case meanings = "m"
        case extraMeanings = "x"
        case index = "i"
        case termTags = "l"
        case dictionary = "a"
    }
    
    public init(term: String = "",
                kana: String = "",
                meaningTags: [String] = [],
                explicitType: String = "",
                meanings: [String] = [],
                extraMeanings: [[String : String]] = [],
                index: Int = 0,
                termTags: [String] = [],
                dictionary: String = "") {
        self.term = term
        self.kana = kana
        self.meaningTags = meaningTags
        self.explicitType = explicitType
        self.meanings = meanings
        self.extraMeanings = extraMeanings
        self.index = index
        self.termTags = termTags
        self.dictionary = dictionary
    }
}

public protocol TaihenCustomDictionary: Codable {
    var name: String { get set }
    var revision: String { get set }
    var tags: [TaihenCustomDictionaryTag] { get set }
    var terms: [TaihenCustomDictionaryTerm] { get set }
}

public class ConcreteTaihenCustomDictionary: TaihenCustomDictionary {
    public var name: String = ""
    public var revision: String = ""
    public var tags: [TaihenCustomDictionaryTag] = []
    public var terms: [TaihenCustomDictionaryTerm] = []
    
    public init(name: String = "",
                  revision: String = "",
                  tags: [TaihenCustomDictionaryTag] = [],
                  terms: [TaihenCustomDictionaryTerm] = []) {
        self.name = name
        self.revision = revision
        self.tags = tags
        self.terms = terms
    }
}
