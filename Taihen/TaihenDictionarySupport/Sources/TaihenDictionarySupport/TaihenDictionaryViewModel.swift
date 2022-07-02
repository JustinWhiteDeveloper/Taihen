import Foundation

public struct TaihenDictionaryViewModel: Codable, Equatable {
    public let groupTerm: String
    public let kana: String
    public var terms: [TaihenCustomDictionaryTerm]
    public var tags: [String]
    
    public init(groupTerm: String, kana: String, terms: [TaihenCustomDictionaryTerm], tags: [String]) {
        self.groupTerm = groupTerm
        self.kana = kana
        self.terms = terms
        self.tags = tags
    }
}

extension ConcreteTaihenCustomDictionary {
    
    private var kanjiDictionary: [String: [TaihenDictionaryViewModel]] {
        var dict: [String: [TaihenDictionaryViewModel]] = [:]

        for term in terms {
            if dict[term.term] == nil {
                let model = TaihenDictionaryViewModel(groupTerm: term.term,
                                                            kana: term.kana,
                                                            terms: [term],
                                                            tags: term.termTags)
                dict[term.term] = [model]
            } else {
                let items = dict[term.term]!
                for (index, model) in items.enumerated() {
                    if term.term == model.groupTerm {
                        dict[term.term]?[index].terms.append(term)
                        
                        //remove "" chars
                        let filteredTags = term.termTags.filter({ $0.count > 0 })
                        
                        var tagsArray = dict[term.term]?[index].tags ?? []
                        tagsArray.append(contentsOf: filteredTags)
                        
                        dict[term.term]?[index].tags = Array(Set(tagsArray))
                        break
                    }
                }
            }
        }
        
        return dict
    }
    
    public var termDict: [String: [TaihenDictionaryViewModel]] {
        
        var dict: [String: [TaihenDictionaryViewModel]] = [:]
               
        let kanjiDict = kanjiDictionary
        var kanaDict: [String: [TaihenDictionaryViewModel]] = [:]
                
        let vals: [[TaihenDictionaryViewModel]] = Array(kanjiDict.values)
        
        for val in vals {
            if let firstKana = val.first?.kana {
                
                if (kanaDict[firstKana] == nil) {
                    kanaDict[firstKana] = val
                } else {
                    for item in val  {
                        kanaDict[firstKana]?.append(item)
                    }
                }
            }
        }
        
        dict.merge(kanaDict)  { (_, new) in new }
        dict.merge(kanjiDict)  { (_, new) in new }
        
        return dict
    }
}
